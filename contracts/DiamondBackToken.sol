pragma solidity ^0.5.0;

import './StandardToken.sol';
import './utils/ReentrancyGuard.sol';

contract DiamondBackToken is StandardToken {
    string public constant name = "DiamondBack";
    string public constant symbol = "DBK";
    uint32 public constant decimals = 2;
    uint256 public INITIAL_SUPPLY = 10000000 * 1 ether;
    uint256 public soldTokens;

    // Crowdfund address
    address public _crowdfundAddress;

    bool public lockTransfers = false;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * Return total value of sold tokens
     * @dev NOTE sold token can override with setToken
     */
    function getSoldTokens() public view returns (uint256) {
        return soldTokens;
    }

    /**
     * @param crowdfundAddress Address
     */
    constructor(address crowdfundAddress) public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        _crowdfundAddress = crowdfundAddress;
    }

    /**
     * @dev WIP
     */
    modifier onlyOwner() {
        require(msg.sender == _crowdfundAddress);
        _;
    }

    /**
     * @param _value Uint256
     * @dev Overrides sold token value
     */
    function setSoldTokens(uint256 _value) public onlyOwner {
        soldTokens = _value;
    }

    function acceptTokens(address _from, uint256 _value) public onlyOwner returns (bool){
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_crowdfundAddress] = balances[_crowdfundAddress].add(_value);
        emit Transfer(_from, _crowdfundAddress, _value);
        return true;
    }

    // Override ERC20 transfer
    function transfer(address _to, uint256 _value) public returns(bool){
        if (msg.sender != _crowdfundAddress){
            require(!lockTransfers, "Transfers operations not allowed");
        }
        return super.transfer(_to, _value);
    }

     // Override ERC20 transferFrom
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        if (msg.sender != _crowdfundAddress){
            require(!lockTransfers, "Transfers operations not allowed");
        }
        return super.transferFrom(_from,_to,_value);
    }

    function lockTransfer(bool _lock) public onlyOwner {
        lockTransfers = _lock;
    }

    /**
     * @dev fallback function
     * This contract not support ether
     */

    function () external payable {
        // The contract don`t receive ether
        revert();
    }

}
