// File: contracts/interfaces/IUniswapV2Router01.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/interfaces/IUniswapV2Router02.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/interfaces/IUniswapV2Factory.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IUniswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: contracts/interfaces/IUniswapV2Pair.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/interfaces/IFreeFromUpTo.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

// File: contracts/interfaces/IBalancer.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IBalancer {
  function treasury (  ) external view returns ( address payable );
  function setTreasury ( address treasuryN ) external;
  function rebalance ( address rewardRecp ) external returns ( uint256 );
  function AddLiq (  ) external returns (bool);
}

// File: contracts/libraries/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/libraries/TransferHelper.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferWithReturn(address token, address to, uint value) internal returns (bool) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

// File: contracts/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ReflectiveToken.sol

pragma solidity >=0.6.0 <0.8.0;




contract ReflectiveToken is IERC20 , Ownable {
    using SafeMath for uint256;

    // Mapping from users to reflection owned
    mapping (address => uint256) private _rOwned;
    // Mapping from users to token
    mapping (address => uint256) private _tOwned;
    // Mapping for allowances
    mapping (address => mapping (address => uint256)) private _allowances;
    // Mapping from users to their fee status
    mapping(address => bool) public isFeeless;
    ///Mapping fro users to their reward status
    mapping (address => bool) private _isExcluded;
    // List of all excluded user addresses
    address[] private _excluded;
    // 2^256 -1
    uint256 private constant MAX = ~uint256(0);
    // One septilllion 10^24
    uint256 private _tTotal = 1000000 ether;
    // 1.157920×10^77
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    // Total fees collected through transfers
    uint256 private _tFeeTotal;

    string private _name = "Reflective Token";
    string private _symbol = "RFT";
    uint8 private _decimals = 18;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Redestributed(address from, uint256 t, uint256 rAmount, uint256 tAmount);

    constructor () public {
         uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("name")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /// @notice Return total fees
    /// @return {_tFeeTotal} total fees
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    /* @notice This function add {tAmount} to {_tFeeTotal} from sender balance
    * @param {tAmount} transfer amount
    */
    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    /// @notice This function calculate how many reflections per token
    /// @param {tAmount} transfer amount
    /// @param {deductTransferFee} flag for fees deduction
    /// @return reflection amount
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    /// @notice This function calculate how many tokens per reflection
    /// @dev In the starting reflection value should be larger or you can get an idea
    /// by running {reflectionFromToken} to get reflection per token
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

     /// @notice This function will exclude the account from rewarding.
    /// This account will not receive rewards anymore.
    /// @param account address of account which will be excluded from reward.
    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /// @notice This function will include the account for rewards.
    /// This account will receive rewards .
    /// @param account address of account which will be included for rewards
    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /* @notice This function amount according to scanerio
    * @param {sender} sender address
    * @param {recipient} recipient address
    * @param {amount} sender amount
    */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    /* @notice This function get reflection & transfer values (including reflection & transfer fees).  
    * subtract sender reflection amount from his reflection balance
    * add reflection transfer amount to the recipient transfer balance
    * @param {sender} sender address
    * @param {recipient} recipient address
    * @param {tAmount} transfering amount
    */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);

        if (isFeeless[sender] || isFeeless[recipient]) {
            rTransferAmount = rTransferAmount.add(rFee);
            tTransferAmount = tTransferAmount.add(tFee);
        } else {
            _reflectFee(rFee, tFee);
            emit Redestributed(sender, 1, rAmount, tAmount);
        }

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    /* @notice This function get reflection & transfer values (including reflection & transfer fees).
    * subtract sender reflection amount from his reflection balance
    * add reflection transfer amount to the recipient transfer balance
    * add reflection transfer amount to the recipient reflection balance
    * @param {sender} sender address
    * @param {recipient} recipient address
    * @param {tAmount} transfering amount
    */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);

        if (isFeeless[sender] || isFeeless[recipient]) {
            rTransferAmount = rTransferAmount.add(rFee);
            tTransferAmount = tTransferAmount.add(tFee);
        } else {
            _reflectFee(rFee, tFee);
            emit Redestributed(sender, 2, rAmount, tAmount);
        }

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    /* @notice This function get reflection & transfer values (including reflection & transfer fees).
    * subtract sender transfer amount from his transfer balance  
    * subtract sender reflection amount from his reflection balance 
    * Add reflection transfer amount to the recipient reflection balance
    * @param {sender} sender address
    * @param {recipient} recipient address
    * @param {tAmount} transfer amount
    */
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);

        if (isFeeless[sender] || isFeeless[recipient]) {
            rTransferAmount = rTransferAmount.add(rFee);
            tTransferAmount = tTransferAmount.add(tFee);
        } else {
            _reflectFee(rFee, tFee);
            emit Redestributed(sender, 3, rAmount, tAmount);
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    /* @notice This function get reflection & transfer values (including reflection & transfer fees).
    * subtract sender transfer amount from his transfer balance  
    * subtract sender reflection amount from his reflection balance 
    * Add reflection transfer amount to the recipient reflection balance
    * Add transfer amount to the recipient transfer balance
    * @param {sender} sender address
    * @param {recipient} recipient address
    * @param {tAmount} transfer amount
    */
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);

        if (isFeeless[sender] || isFeeless[recipient]) {
            rTransferAmount= rTransferAmount.add(rFee);
            tTransferAmount = tTransferAmount.add(tFee);
        } else {
            _reflectFee(rFee, tFee);
            emit Redestributed(sender, 4, rAmount, tAmount);
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    /* @notice Reflect fees, subtract {rFee} from {_rTotal} and add {tFee} in {_tFeeTotal}
    * @param {rFee} reflection fee
    * @param {tFee} transfer fee
    */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    /* @notice Calculate Transfer and Reflection values
    * @param {tAmount} Total transfer amount
    * @return {rAmount} Reflection amount
    * @return {rTransferAmount} Reflection transfer amount
    * @return {rFee} reflection fees
    * @return {tTransferAmount} transfer amount
    * @return {tFee} transfer fee
    */
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    /* @notice Calculate Transfer values by subtract 1% fee and 99% as a transfer amount
    * @param {tAmount} transfer amount 
    * @return tTransferAmount
    * @return tFee
    */
    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    /* @notice Calculate Reflection values
    * @param {tAmount} transfer amount 
    * @param {tFee} transfer fee 
    * @param {currentRate} current rate of reflection
    * @return {rAmount} rTransferAmount rFee
    */
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    /* @notice Calculate current rate of token.
    * @return Current rate by simple formula (reflection remaining supply / total remaining supply)
    */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    /* @notice Calculate current reflection tokens supply and total tokens supply
    * by subtracting users current balances
    * @return reflection and total supply
    */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _rOwned[account] = _rOwned[account].sub(amount, "ERC20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount, "ERC20: burn amount exceeds balance");
        emit Transfer(account, address(0), amount);
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'Pancake: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'Pancake: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// File: contracts/SyntLayer.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
//Import abstractions








// import Reflective token (safemoon)

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
