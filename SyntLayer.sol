// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
//Import abstractions
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IFreeFromUpTo.sol";
import "./interfaces/IBalancer.sol";
import "./libraries/SafeMath.sol";
import "./libraries/TransferHelper.sol";
import "./Ownable.sol";
// import Reflective token (safemoon)
import "./ReflectiveToken.sol";
//Import uniswap interfaces


contract SyntLayer is ReflectiveToken {
    using SafeMath for uint256;

    event Rebalance(uint256 tokenBurnt);
    event RewardLiquidityProviders(uint256 liquidityRewards);
    /// @dev UniswapV2Router02 contract address
    /// 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ethereum mainnet
    /// 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ethereum rinkeby
    /// 0xA051966f823DEF0433Ac9eA84B0C5EFBA5011a08 bsc testnet
    /// 0x6760F6553CD9D2677f27216E9cD85402c5Ff1EC7 bsc testnet
    /// 0x6728f3c8241C44Cc741C9553Ff7824ba9E932A4A bsc mainnet
    /// 0x788B8EcE56F2C0eD41f31D7cd172276addCD7F99 bsc mainnet
    /// @dev PancakeRouter contract address
    /// 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F bsc mainnet
    /// 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 bsc testnet
    /// 0xf70FcEa64f69A44D626C6aD4E62d064A9A8bF62C bsc testnet
    /// 0x7Bf2287D65D199027bFa1a62B39828C7505A8a3D bsc testnet
    address public uniswapV2Router = 0x7Bf2287D65D199027bFa1a62B39828C7505A8a3D; 
    
    // @dev For Storing your pair contract address (UniswapV2Pair)
    address public uniswapV2Pair = address(0);

    address payable public treasury;

    mapping(address => bool) public unlockedAddr;

    IUniswapV2Router02 router = IUniswapV2Router02(uniswapV2Router);
    IUniswapV2Pair iuniswapV2Pair = IUniswapV2Pair(uniswapV2Pair);
    // 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c  BSC mainnet
    // 0x000000009f7F0ac4E40734FE570Ab3227cD6B5A0 BSC testnet
    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x000000009f7F0ac4E40734FE570Ab3227cD6B5A0); // On BSC testnet
    

    uint256 public minRebalanceAmount;
    uint256 public lastRebalance;
    uint256 public rebalanceInterval;
    uint256 public liqAddBalance = 0;

    uint256 constant INFINITE_ALLOWANCE = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // Liquidity Providers locked time
    uint256 public lpUnlocked;
    bool public locked;
    //Use CHI to save on gas on rebalance
    bool public useCHI = false;
    bool approved = false;
    bool doAddLiq = true;

    /// @notice Liq Add Cut fee at 1% initially
    uint256 public LIQFEE = 100;
    /// @notice LiqLock is set at 0.2%
    uint256 public LIQLOCK = 20;
    /// @notice Rebalance amount is 2.5%
    uint256 public REBALCUT = 250;
    /// @notice Caller cut is at 2%
    uint256 public CALLCUT = 200;
    /// @notice Fee BASE
    uint256 constant public BASE = 10000;

    IBalancer balancer;

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *
                           msg.data.length;
        if(useCHI){
            if(chi.balanceOf(address(this)) > 0) {
                chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
            }
            else {
                chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
            }
        }
    }
    /*
    * @locked 
    * @balancer 
    * @treasury 
    * @isFeeless 
    * @lpUnlocked 
    * @unlockedAddr 
    * @lastRebalance 
    * @rebalanceInterval 
    */
    constructor(address balancerAddr) public {
        lastRebalance = block.timestamp;
        rebalanceInterval = 1 seconds;
        lpUnlocked = block.timestamp + 90 days;
        minRebalanceAmount = 20 ether;
        treasury = msg.sender;
        balancer = IBalancer(balancerAddr);
        locked = true;
        unlockedAddr[msg.sender] = true;
        unlockedAddr[balancerAddr] = true;
        isFeeless[address(this)] = true;
        isFeeless[balancerAddr] = true;
        isFeeless[msg.sender] = true;
    }

    /*
    * @newBalancer
    * This function can only bee called by owner
    * set new balancer status isFeeless to true 
    * set new balancer status unlockedAddr to true 
    */
    function setBalancer(address newBalancer) public onlyOwner {
        balancer = IBalancer(newBalancer);
        isFeeless[newBalancer] = true;
        unlockedAddr[newBalancer] = true;
    }

    /* Fee getters */
    function getLiqAddBudget(uint256 amount) public view returns (uint256) {
        return amount.mul(LIQFEE).div(BASE);
    }

    function getLiqLockBudget(uint256 amount) public view returns (uint256) {
        return amount.mul(LIQLOCK).div(BASE);
    }

    function getRebalanceCut(uint256 amount) public view returns (uint256) {
        return amount.mul(REBALCUT).div(BASE);
    }

    /* Calculate Caller Cut
    * i.e (amount * CALLCUT) / BASE
    *     (10 * 200 ) / 10000  => 0.2
    */
    function getCallerCut(uint256 amount) public view returns (uint256) {
        return amount.mul(CALLCUT).div(BASE);
    }

    /*
    * @newOwner
    *  Toggle current owner isFeeless status
    *  Toggle current owner unlockedAddr status
    */
    function transferOwnership(address newOwner) public override onlyOwner {
        //First remove feelet set for current owner
        toggleFeeless(owner());
        //Remove unlock flag for current owner
        toggleUnlockable(owner());
        //Add feeless for new owner
        toggleFeeless(newOwner);
        //Add unlocked for new owner
        toggleUnlockable(newOwner);
        //Transfer ownersip
        super.transferOwnership(newOwner);
    }

    /*
    * @from sender address
    * @to receiver address
    * @amount sending amount
    *transfer function with liq add and liq rewards
    */
    function _transfer(address from, address to, uint256 amount) internal override  {
        // calculate liquidity lock amount
        // dont transfer burn from this contract
        // or can never lock full lockable amount
        if(locked && !unlockedAddr[from])
            revert("Locked until end of distribution");

        if (!isFeeless[from] && !isFeeless[to] && !locked) {
            uint256 liquidityLockAmount = getLiqLockBudget(amount);
            uint256 LiqPoolAddition = getLiqAddBudget(amount);
            //Transfer to liq add amount
            super._transfer(from, address(this), LiqPoolAddition);
            liqAddBalance = liqAddBalance.add(LiqPoolAddition);
            //Transfer to liq lock amount
            super._transfer(from, address(this), liquidityLockAmount);
            //Amount that is ending up after liq rewards and liq budget
            uint256 totalsub = LiqPoolAddition.add(liquidityLockAmount);
            super._transfer(from, to, amount.sub(totalsub));
        }
        else {
            super._transfer(from, to, amount);
        }
    }

    // receive eth from uniswap swap
    receive () external payable {}

    /*
    * @Initialize the Pair on UniSwap
    * It will use UniSwap router reference to get UniSwap Factory reference to create pair with WETH i.e YOURTOKEN/WETH
    * and save the pair address in uniswapV2Pair variable
    */
    function initPair() public {
        // Create a uniswap pair for this new token
        // 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd BSC testnet WBNB address
        uniswapV2Pair = IUniswapFactory(router.factory()).createPair(address(this), router.WETH());
        //Set uniswap pair interface
        iuniswapV2Pair = IUniswapV2Pair(uniswapV2Pair);
    }

    /*
    * @pair
    * Set pair address
    */
    function setUniPair(address pair) public onlyOwner {
        uniswapV2Pair = pair;
        iuniswapV2Pair = IUniswapV2Pair(uniswapV2Pair);
    }

    /*
    * @ Set smart contract to unlocked status 
    */
    function unlock() public onlyOwner {
        locked = false;
    }

    /*
    * @treasuryN
    * set Treasury address
    */
    function setTreasury(address treasuryN) public onlyOwner {
        treasury = payable(treasuryN);
        balancer.setTreasury(treasuryN);
    }

    /* Fee setters */

    /*
    * @newFee
    * set Liquidty Fee 
    */
    function setLiqFee(uint newFee) public onlyOwner {
        LIQFEE = newFee;
    }

    /*
    * @newFee
    * set Liquidty Lock Cut Fee 
    */
    function setLiquidityLockCut(uint256 newFee) public onlyOwner {
        LIQLOCK = newFee;
    }

     /*
    * @newFee
    * set Rebalance Cut Fee 
    */
    function setRebalanceCut(uint256 newFee) public onlyOwner {
        REBALCUT = newFee;
    }

    /*
    * @newFee
    * set Caller Reward Cut Fee 
    */
    function setCallerRewardCut(uint256 newFee) public onlyOwner {
        CALLCUT = newFee;
    }

    /*
    * Toggle CHI status either we want to enable it or not 
    */
    function toggleCHI() public onlyOwner {
        useCHI = !useCHI;
    }

    /*
    * @_interval
    * Set rebalanceInterval
    */
    function setRebalanceInterval(uint256 _interval) public onlyOwner {
        rebalanceInterval = _interval;
    }

    /*
    * @dest Destination address
    * @amount
    * Transfer Given amount to the given address
    */
    function _transferLP(address dest,uint256 amount) internal{
        iuniswapV2Pair.transfer(dest, amount);
    }

    function unlockLPPartial(uint256 amount) public onlyOwner {
        require(block.timestamp > lpUnlocked, "Not unlocked yet");
        _transferLP(msg.sender,amount);
    }

    function unlockLP() public onlyOwner {
        require(block.timestamp > lpUnlocked, "Not unlocked yet");
        uint256 amount = iuniswapV2Pair.balanceOf(address(this));
        _transferLP(msg.sender, amount);
    }

    function toggleFeeless(address _addr) public onlyOwner {
        isFeeless[_addr] = !isFeeless[_addr];
    }

    function toggleUnlockable(address _addr) public onlyOwner {
        unlockedAddr[_addr] = !unlockedAddr[_addr];
    }

    function setMinRebalanceAmount(uint256 amount_) public onlyOwner {
        minRebalanceAmount = amount_;
    }

    function rebalanceable() public view returns (bool) {
        return block.timestamp > lastRebalance.add(rebalanceInterval);
    }

    function hasMinRebalanceBalance(address addr) public view returns (bool) {
        return balanceOf(addr) >= minRebalanceAmount;
    }

    /*
    * @liquidityRewards
    * Reward 
    */
    function _rewardLiquidityProviders(uint256 liquidityRewards) private {
        super._transfer(address(this), uniswapV2Pair, liquidityRewards);
        iuniswapV2Pair.sync();
        emit RewardLiquidityProviders(liquidityRewards);
    }

    function remLiquidity(uint256 lpAmount) private returns(uint ETHAmount) {
        iuniswapV2Pair.approve(uniswapV2Router, lpAmount);
        (ETHAmount) = router
            .removeLiquidityETHSupportingFeeOnTransferTokens(
                address(this),
                lpAmount,
                0,
                0,
                address(balancer),
                block.timestamp
            );
    }

    function ApproveInf(address tokenT,address spender) internal{
        TransferHelper.safeApprove(tokenT,spender,INFINITE_ALLOWANCE);
    }

    function toggleAddLiq() public onlyOwner {
        doAddLiq = !doAddLiq;
    }

    function rebalanceLiquidity() public discountCHI {
        require(hasMinRebalanceBalance(msg.sender), "!hasMinRebalanceBalance");
        require(rebalanceable(), '!rebalanceable');
        lastRebalance = block.timestamp;

        if(!approved) {
            ApproveInf(address(this),uniswapV2Router);
            ApproveInf(uniswapV2Pair,uniswapV2Router);
            approved = true;
        }
        //Approve CHI incase its enabled
        if(useCHI) ApproveInf(address(chi),address(chi));
        // lockable supply is the token balance of this contract minus the liqaddbalance
        if(lockableSupply() > 0)
            _rewardLiquidityProviders(lockableSupply());

        uint256 amountToRemove = getRebalanceCut(iuniswapV2Pair.balanceOf(address(this)));
        // Sell half of balance tokens to eth and add liq
        if(balanceOf(address(this)) >= liqAddBalance && liqAddBalance > 0 && doAddLiq) {
            //Send tokens to balancer
            super._transfer(address(this),address(balancer),liqAddBalance);
            require(balancer.AddLiq(),"!AddLiq");
            liqAddBalance = 0;
        }
        // needed in case contract already owns eth
        remLiquidity(amountToRemove);
        uint _locked = balancer.rebalance(msg.sender);
        //Sync after changes
        iuniswapV2Pair.sync();
        emit Rebalance(_locked);
    }

    // returns token amount
    function lockableSupply() public view returns (uint256) {
        return balanceOf(address(this)) > 0 ? balanceOf(address(this)).sub(liqAddBalance,"underflow on lockableSupply") : 0;
    }

    // returns token amount
    function lockedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = iuniswapV2Pair.totalSupply();
        uint256 lpBalance = lockedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = balanceOf(uniswapV2Pair);
        uint256 _lockedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _lockedSupply;
    }

    // returns token amount
    function burnedSupply() external view returns (uint256) {
        uint256 lpTotalSupply = iuniswapV2Pair.totalSupply();
        uint256 lpBalance = burnedLiquidity();
        uint256 percentOfLpTotalSupply = lpBalance.mul(1e12).div(lpTotalSupply);

        uint256 uniswapBalance = balanceOf(uniswapV2Pair);
        uint256 _burnedSupply = uniswapBalance.mul(percentOfLpTotalSupply).div(1e12);
        return _burnedSupply;
    }

    // returns LP amount, not token amount
    function burnableLiquidity() public view returns (uint256) {
        return iuniswapV2Pair.balanceOf(address(this));
    }

    // returns LP amount, not token amount
    function burnedLiquidity() public view returns (uint256) {
        return iuniswapV2Pair.balanceOf(address(0));
    }

    // returns LP amount, not token amount
    function lockedLiquidity() public view returns (uint256) {
        return burnableLiquidity().add(burnedLiquidity());
    }
}