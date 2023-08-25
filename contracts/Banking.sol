// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

///@author chisomchris
///@title Banking Smart Contract Vault for saving and sending ethers

contract Banking {
    struct User {
        address id;
        uint balance;
        uint createdAt;
    }

    event Transfer(address indexed from, address indexed to, uint amount);
    event Withdrawal(address indexed by, uint amount);
    event Deposit(address indexed by, uint amount);

    /// invalid address
    error InvalidAddress(address addr);
    /// user already exist
    error UserAlreadyExist(address addr);
    /// user does not exist
    error UserDoesNotExist(address addr);
    /// insufficient funds: requested `amount`, `balance` available
    error InsufficientFund(uint amount, uint balance);

    address owner;
    string constant name = "Dudely Smart Banking";
    mapping(address => User) accounts;

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "not an EOA");
        _;
    }
    modifier validAddress(address _address) {
        require(
            _address != address(0) || _address == address(_address),
            "not an EOA"
        );
        _;
    }

    constructor() payable {
        owner = msg.sender;
        _initUser(owner);
        accounts[owner].balance += msg.value;
        (bool success, ) = payable(address(this)).call{value: msg.value}("");
        require(success, "Transaction Failed");
    }

    receive() external payable {
        emit Transfer(msg.sender, address(this), msg.value);
    }

    function register() public onlyEOA {
        _initUser(msg.sender);
    }

    function vault() public view returns (uint) {
        return address(this).balance;
    }

    function balanceOf(address addr) public view returns (uint) {
        if (!_isRegistered(addr)) revert UserDoesNotExist(addr);
        return accounts[addr].balance;
    }

    function myBalance() public view onlyEOA returns (uint) {
        return balanceOf(msg.sender);
    }

    function getUser(address addr) public view returns (address, uint) {
        if (!_isRegistered(addr)) revert UserDoesNotExist(addr);
        return (accounts[addr].id, accounts[addr].balance);
    }

    function transfer(address to, uint amount) public onlyEOA {
        if (!_isRegistered(msg.sender)) revert UserDoesNotExist(msg.sender);
        if (!_isRegistered(to)) revert UserDoesNotExist(to);
        User storage sender = accounts[msg.sender];

        if (sender.balance < amount)
            revert InsufficientFund(amount, sender.balance);

        sender.balance -= amount;
        accounts[to].balance += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function withdraw(uint amount) public onlyEOA {
        if (!_isRegistered(msg.sender)) revert UserDoesNotExist(msg.sender);
        User storage sender = accounts[msg.sender];
        if (sender.balance < amount)
            revert InsufficientFund(amount, sender.balance);

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Transaction Failed");
        sender.balance -= amount;
        emit Withdrawal(msg.sender, amount);
    }

    function deposit() public payable onlyEOA {
        if (!_isRegistered(msg.sender)) revert UserDoesNotExist(msg.sender);
        require(msg.value > 0, "Invalid Amount");
        (bool sent, ) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Transaction Failed");
        accounts[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function _isRegistered(address addr) private view returns (bool) {
        return
            (accounts[addr].createdAt == 0 || accounts[addr].id == address(0))
                ? false
                : true;
    }

    function _initUser(address _user) private validAddress(_user) {
        if (accounts[_user].id != address(0)) revert UserAlreadyExist(_user);
        User storage user = accounts[_user];
        user.id = _user;
        user.createdAt = block.timestamp;
    }
}
