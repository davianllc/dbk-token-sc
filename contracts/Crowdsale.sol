pragma solidity ^0.5.0;

import './properties/Ownable.sol';
import './DiamondBackToken.sol';
import './lib/SafeMath.sol';

contract Crowdsale is Ownable {
    using SafeMath for uint; 

    // Addresses
    address contractAddress = address(this);

    // Published timestamp
    uint256 public publishedAt;

    // Private sale ends timestamp
    uint256 public privateSaleEndsAt;
    uint256 public publicPreSaleEndsAt;

    // DBK token
    DiamondBackToken public token = new DiamondBackToken(contractAddress);

    // Events
    event LogStateSwitch(State newState);

    enum State { 
        PREFLIGHT,
        CROWDSALE,
        MIGRATE
    }
    State public currentState = State.PREFLIGHT;

    // TeamAddress public teamAddress = new TeamAddress();
    address public teamAddress;
    uint256 public teamValue;
    /**
     * @dev after deployment, contract state raise to next stage
     */
    constructor() public {
        publishedAt = uint256(block.timestamp);
        privateSaleEndsAt = 1551287903;
        publicPreSaleEndsAt = 1551288795;
        teamAddress = address(1);
        teamValue = 300000;

        // ISSUE TEAM TOKENS
        issueTokens(teamAddress, teamValue);

        // Stage CrowdSale is enable
        nextState();
    }

    function nextState() internal {
        currentState = State(uint(currentState) + 1);
        emit LogStateSwitch(currentState);
    }

    function lockExternalTransfer() public onlyOwner {
        token.lockTransfer(true);
    }

    function unlockExternalTransfer() public onlyOwner {
        token.lockTransfer(false);
    }

    function getDiscount() public view returns(uint256) {
        uint256 extra = 0;
        if (privateSaleEndsAt >= block.timestamp) {
            extra = 20;
        } else if (publicPreSaleEndsAt >= block.timestamp){ 
            extra = 10;
        } else { 
            extra = 5;
        }
        return extra;
    }

    function getDiscountedPrice(uint256 value) public view returns(uint256) {
        uint256 discount = getDiscount();
        if (discount > 0) {
            return value + value.mul(discount).div(100);
        }
        return value;
    }

    function getSoldTokens() public onlyOwner view returns(uint256) {
        uint256 soldTokens = token.getSoldTokens();
        return soldTokens;
    }

    function issueTokens(address _investorAddress, uint256 _value) public restricted {
        require(_investorAddress != address(0));
        require(_value >= 1);

        uint256 soldTokens = token.getSoldTokens();
        uint256 value = _value;

        value = value.mul(1 ether);

        if (currentState != State.PREFLIGHT){
            value = getDiscountedPrice(value);
        }

        soldTokens = soldTokens.add(value);
        token.setSoldTokens(soldTokens);
        token.transfer(_investorAddress, value);
    } 

    function() external payable {
        // The contract don`t receive ether
        revert();
    }    

}