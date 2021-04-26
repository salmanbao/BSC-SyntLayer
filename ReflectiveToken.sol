pragma solidity >=0.6.0 <0.8.0;

import "./Ownable.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

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