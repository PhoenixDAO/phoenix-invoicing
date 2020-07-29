pragma solidity ^0.5.0;

import "../SnowflakeResolver.sol";
import "../interfaces/IdentityRegistryInterface.sol";
import "../interfaces/SnowflakeInterface.sol";


contract Resolver is SnowflakeResolver {
    SnowflakeInterface private snowflake;
    IdentityRegistryInterface private identityRegistry;

    constructor (address snowflakeAddress)
        SnowflakeResolver("Sample Resolver", "This is a sample Snowflake resolver.", snowflakeAddress, true, true)
        public
    {
        setSnowflakeAddress(snowflakeAddress);
    }

    // set the snowflake address, and phoenix token + identity registry contract wrappers
    function setSnowflakeAddress(address snowflakeAddress) public onlyOwner() {
        super.setSnowflakeAddress(snowflakeAddress);
        snowflake = SnowflakeInterface(snowflakeAddress);
        identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
    }

    // implement signup function
    function onAddition(uint ein, uint allowance, bytes memory) public senderIsSnowflake() returns (bool) {
        require(allowance >= 2000000000000000000, "Must set an allowance of >=2 PHNX.");
        snowflake.withdrawSnowflakeBalanceFrom(ein, address(this), allowance / 2);
        return true;
    }

    // implement removal function
    function onRemoval(uint, bytes memory) public senderIsSnowflake() returns (bool) {}

    // example function to test allowAndCall
    function transferSnowflakeBalanceFromAllowAndCall(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender));
        snowflake.transferSnowflakeBalanceFrom(einFrom, einTo, amount);
    }

    // example functions to test *From token functions
    function transferSnowflakeBalanceFrom(uint einTo, uint amount) public {
        snowflake.transferSnowflakeBalanceFrom(identityRegistry.getEIN(msg.sender), einTo, amount);
    }

    function withdrawSnowflakeBalanceFrom(address to, uint amount) public {
        snowflake.withdrawSnowflakeBalanceFrom(identityRegistry.getEIN(msg.sender), to, amount);
    }

    function transferSnowflakeBalanceFromVia(address via, uint einTo, uint amount) public {
        snowflake.transferSnowflakeBalanceFromVia(identityRegistry.getEIN(msg.sender), via, einTo, amount, hex"");
    }

    function withdrawSnowflakeBalanceFromVia(address via, address to, uint amount) public {
        snowflake.withdrawSnowflakeBalanceFromVia(identityRegistry.getEIN(msg.sender), via, to, amount, hex"");
    }

    // example functions to test *To token functions
    function _transferPhoenixBalanceTo(uint einTo, uint amount) public onlyOwner {
        transferPhoenixBalanceTo(einTo, amount);
    }

    function _withdrawPhoenixBalanceTo(address to, uint amount) public onlyOwner {
        withdrawPhoenixBalanceTo(to, amount);
    }

    function _transferPhoenixBalanceToVia(address via, uint einTo, uint amount) public onlyOwner {
        transferPhoenixBalanceToVia(via, einTo, amount, hex"");
    }

    function _withdrawPhoenixBalanceToVia(address via, address to, uint amount) public onlyOwner {
        withdrawPhoenixBalanceToVia(via, to, amount, hex"");
    }
}
