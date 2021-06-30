pragma solidity ^0.7.2;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor() {}

    /**
     * @notice Get the sender's address
     * @return this msg sender address
     */
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    /**
     * @notice Get msg data
     * @return this msg data
     */
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    /**
     * @notice Adds two numbers
     * @dev If first numbers greater than second numbers, return an error on overflow
     * @return The sum of two numbers
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @notice Subtracts two numbers
     * @dev If subtrahend is greater than minuend, returns an error on overflow
     * @return Difference between two numbers
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @notice Subtracts two numbers
     * @dev If subtrahend is greater than minuend, returns an errorMessage
     * @return Difference between two numbers
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /**
     * @notice Multiplies two numbers
     * @dev Multiplies two numbers, returns an error on overflow
     * @return Product of two numbers
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @notice Divide two numbers
     * @dev If dividend by zero, returns an error
     * @return Quotient of two numbers
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @notice Divide two numbers
     * @dev If dividend by zero, returns an errorMessage
     * @return Quotient of two numbers
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

library Address {
    /**
     * @notice Determine whether the address matches
     * @param account The address of contract
     * @return bool true or false
     */
    function isContract(address account) internal view returns (bool) {
        bytes32 codeHash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codeHash := extcodehash(account)
        }
        return (codeHash != 0x0 && codeHash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    /**
     * @notice Transfer token to user address, the sender provides tokens
     * @param Tokens to be transferred
     * @param Recipient account address
     * @param Number of tokens transferred
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @notice Transfer token to user address
     * @param Tokens to be transferred
     * @param Sender account address
     * @param Recipient account address
     * @param Number of tokens transferred
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @notice Approve `spender` to transfer up to `value` from `src`
     * @dev This will overwrite the approval amount for `spender`
     * @param spender The address of the account which may transfer tokens
     * @param value The number of tokens that are approved
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @notice Add a new amount of allowance to the sender
     * @dev This will overwrite the approval amount for `spender`
     * @param spender The address of the account which may transfer tokens
     * @param value The number of tokens that are approved
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).add(value);
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @notice Reduce the number of new allowances to the sender
     * @dev This will overwrite the approval amount for `spender`
     * @param spender The address of the account which may transfer tokens
     * @param value The number of tokens that are approved
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @notice The proxy calls the token
     * @dev Method of calling token contract through abi
     * @param token Token to be substituted
     * @param data Binary data of abi
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returnData) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returnData.length > 0) {
            require(
                abi.decode(returnData, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract DaoStorage {
    /**
     * @notice governance administrator for this contract
     */
    address public governance;

    /**
     * @notice MARA contract address
     */
    address public mara;

    /**
     * @notice Record the number of blocks locked by each user
     */
    mapping(address => uint256) public lockBlocks;

    /**
     * @notice The number of blocks to be locked
     */
    uint256 public lockTime;

    /**
     * @notice The number of tokens provided by the user
     */
    mapping(address => uint256) private _balances;

    /**
     * @notice The number of user's token approve
     */
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @notice The total supply in the contract
     */
    uint256 private _totalSupply;

    /**
     * @notice dao token name
     */
    string private _name;

    /**
     * @notice dao token symbol
     */
    string private _symbol;

    /**
     * @notice dao token decimal
     */
    uint8 private _decimals;

    /**
     * @notice Restrict users from transferring tokens
     */
    mapping(address => bool) public transferLimitTargets;

    /**
     * @notice Whether to enable transfer restrictions
     */
    bool public enableTransferLimit = true;

    /**
     * @notice Whether to allow external contract calls
     */
    bool public allowContract = false;

    /**
     * @notice Whether to open withdraw
     */
    bool public openWithdraw = false;
}

contract MARADao is IERC20, Context, DaoStorage {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor(
        string memory __name,
        string memory __symbol,
        uint256 _lockTime,
        address _MARA,
        address chef
    ) {
        governance = msg.sender;
        lockTime = _lockTime;
        mara = _MARA;
        _name = __name;
        _symbol = __symbol;
        _decimals = IERC20(_MARA).decimals();

        enableTransferLimit = true;
        transferLimitTargets[chef] = true;
    }

    /**
     * @notice Dao token name
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice Dao token symbol
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Dao token decimal
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    modifier onlyHuman {
        if (!allowContract) {
            require(msg.sender == tx.origin);
            _;
        }
    }

    /**
     * @notice Change the administrator of the contract
     * @param _governance new account address
     */
    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    /**
     * @notice Change the number of locked blocks
     * @param _lt blocks
     */
    function updateLockTime(uint256 _lt) public {
        require(msg.sender == governance, "!governance");
        require(_lt > 0);
        lockTime = _lt;
    }

    /**
     * @notice Change enableTransferLimit
     * @param _e bool true or false
     */
    function toggleTransferLimit(bool _e) public {
        require(msg.sender == governance, "!governance");
        enableTransferLimit = _e;
    }

    /**
     * @notice Change openWithdraw
     * @param _e bool true or false
     */
    function toggleOpenWithdraw(bool _e) public {
        require(msg.sender == governance, "!governance");
        openWithdraw = _e;
    }

    /**
     * @notice Change allowContract
     * @param _e bool true or false
     */
    function toggleAllowContract(bool _e) public {
        require(msg.sender == governance, "!governance");
        allowContract = _e;
    }

    /**
     * @notice open transferLimitTargets
     * @param _a bool true or false
     */
    function addLimitTarget(address _a) public {
        require(msg.sender == governance, "!governance");
        transferLimitTargets[_a] = true;
    }

    /**
     * @notice close transferLimitTargets
     * @param _a bool true or false
     */
    function removeLimitTarget(address _a) public {
        require(msg.sender == governance, "!governance");
        transferLimitTargets[_a] = false;
    }

    /**
     * @notice The user makes a deposit
     * @param _amount token amount
     */
    function deposit(uint256 _amount) public onlyHuman {
        require(_amount > 0, "zero deposit");

        uint256 _before = IERC20(mara).balanceOf(address(this));
        IERC20(mara).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = IERC20(mara).balanceOf(address(this));
        _amount = _after.sub(_before);
        uint256 shares = _amount;
        uint256 oldAmount = balanceOf(msg.sender);

        if (oldAmount == 0) {
            lockBlocks[msg.sender] = block.number.add(lockTime);
        } else {
            uint256 expireBlock = lockBlocks[msg.sender];
            uint256 totalAmount = oldAmount.add(_amount);
            uint256 newAmountShare = _amount.mul(lockTime);

            if (expireBlock > block.number) {
                // (oldAmount * (expireBlock - block.number) + _amount * lockTime) / (oldAmount + _amount)
                uint256 deltaBlocks = expireBlock.sub(block.number);
                uint256 avgLockTime = oldAmount.mul(deltaBlocks).add(newAmountShare).div(totalAmount);
                lockBlocks[msg.sender] = block.number.add(avgLockTime);
            } else {
                // _amount * lockTime / (oldAmount + _amount)
                uint256 avgLockTime = newAmtShare.div(totalAmount);
                lockBlocks[msg.sender] = block.number.add(avgLockTime);
            }
        }

        _mint(msg.sender, shares);
    }

    /**
     * @notice Withdraw all balance
     */
    function withdrawAll() external onlyHuman {
        withdraw(balanceOf(msg.sender));
    }

    /**
     * @notice Withdraw the number of tokens supplied
     * @param _shares token amount
     */
    function withdraw(uint256 _shares) public onlyHuman {
        require(_shares > 0);

        if (!openWithdraw) {
            require(lockBlocks[msg.sender] < block.number);
        }
        uint256 r = _shares;
        _burn(msg.sender, _shares);

        IERC20(mara).safeTransfer(msg.sender, r);
    }

    /**
     * @notice Check whether the user is allowed to withdraw
     * @param user Account address
     * @return If permission to open allows withdrawal return true, else return whether block.number is greater than lockBlocks[user] (bool)
     */
    function canWithdraw(address user) public view returns (bool) {
        if (openWithdraw) {
            return true;
        }
        return block.number >= lockBlocks[user];
    }

    /**
     * @notice Total supply of all users in this contract
     * @return _totalSupply
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Quantity supplied by users
     * @param account User address
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfer a specified number of tokens to other users
     * @param recipient The address of the destination account
     * @param amount The number of tokens to transfer
     * @return true
     */
    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @notice Get the current allowance from `owner` for `spender`
     * @param owner The address of the account which owns the tokens to be spent
     * @param spender The address of the account which may transfer tokens
     * @return _allowances
     */
    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from msg.sender
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved
     * @return true
     */
    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `sender` to `recipient`
     * @param sender The address of the source account
     * @param recipient The address of the destination account
     * @param amount The number of tokens to transfer
     * @return true
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @notice Add the current allowance from msg.sender for `spender`
     * @param spender The address of the account which may transfer tokens
     * @param addedValue The number of tokens that are approved
     * @return true
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool){
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @notice Reduce the current allowance from msg.sender for `spender`
     * @param spender The address of the account which may transfer tokens
     * @param subtractedValue The number of tokens that are approved
     * @return true
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool){
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @notice Transfer a specified number of tokens to other users
     * @param sender The address of the source account
     * @param recipient The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (enableTransferLimit) {
            require(transferLimitTargets[sender] || transferLimitTargets[recipient], "limit transfer targets");
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @notice Record the quantity supplied by the user
     * @param account The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @notice Destroy the quantity supplied by the user
     * @param account The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `owner`
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Destroy the account balance and reduce the approved amount
     * @param account The address of the destination account
     * @param amount The number of tokens that are approved
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "ERC20: burn amount exceeds allowance"
            )
        );
    }
}
