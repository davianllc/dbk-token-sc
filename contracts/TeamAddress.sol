pragma solidity ^0.5.0;

contract TeamAddress {
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}
