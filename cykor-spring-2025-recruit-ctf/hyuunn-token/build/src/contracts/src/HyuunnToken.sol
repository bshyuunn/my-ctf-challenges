// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract HyuunnToken {

    struct AppliedData {
        address user;
        bool applied;
        uint256 blockNumber;
    }

    address public owner;
    mapping(address => AppliedData) public appliedUsers;
    mapping(address => bool) public registeredUsers;

    mapping(address => uint) private _balances;

    string private _name = "Hyuunn Coin";
    string private _symbol = "HYUN";

    constructor() {
        owner = msg.sender;
        registeredUsers[msg.sender] = true;
    }

    modifier notContract() {
        require(msg.sender.code.length == 0 && msg.sender != owner, "You are not the contract");
        _;
    }

    modifier onlyRegistered(address account) {
        require(registeredUsers[account], "You are not registered");
        _;
    }

    function applyForRegistration() public notContract {
        require(!appliedUsers[msg.sender].applied, "You have already applied");
        
        AppliedData storage userAppliedData = appliedUsers[msg.sender];
        userAppliedData.user = msg.sender;
        userAppliedData.applied = true;
        userAppliedData.blockNumber = block.number;
    }

    function confirmRegistration() public notContract {
        require(!registeredUsers[msg.sender], "You are already registered");
        require(appliedUsers[msg.sender].applied, "You have not applied");
        registeredUsers[msg.sender] = true;
        
        AppliedData storage userAppliedData = appliedUsers[msg.sender];
        require(block.number != userAppliedData.blockNumber, "Invalid blockNumber");

        userAppliedData.user = address(0x0);
        userAppliedData.applied = false;
        userAppliedData.blockNumber = 0;
    }

    function deposit(uint256 amount) public payable onlyRegistered(msg.sender) {
        require(msg.value == amount, "Invalid amount");
        _balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public onlyRegistered(msg.sender) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");

        _balances[msg.sender] -= amount;
    }

    function withdrawAll() public onlyRegistered(msg.sender) {
        uint256 amount = _balances[msg.sender];
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");

        _balances[msg.sender] = 0;
    }

    function transfer(address recipient, uint256 amount) public onlyRegistered(msg.sender) onlyRegistered(recipient) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "You are not the owner");
        owner = newOwner;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function getApplied(address account) public view returns (bool) {
        return appliedUsers[account].applied;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}