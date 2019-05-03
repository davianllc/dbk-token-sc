pragma solidity ^0.5.0;

contract Ownable {
    address public owner;
    address public manager;
    address candidate;

    constructor() public {
        owner = msg.sender;
        manager = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier restricted() {
        require(msg.sender == owner || msg.sender == manager);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        candidate = _newOwner;
    }

    function setManager(address _newManager) public onlyOwner {
        manager = _newManager;
    }

    function confirmOwnership() public {
        require(candidate == msg.sender);
        owner = candidate;
        delete candidate;
    }

}
