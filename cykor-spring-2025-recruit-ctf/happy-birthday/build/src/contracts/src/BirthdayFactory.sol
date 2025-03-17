// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Birthday} from "./Birthday.sol";

contract BirthdayFactory {
    Birthday public lastBirthdayContract;

    /*
        Payload format:
        isGifted, giftAmount, giftGiver, birthdayMessage, birthdayPerson, birthYear, birthMonth, birthDay
        All fields use 32 bytes
    */
    function deployBirthdayContract(
        bytes calldata payloads
    ) external payable returns (address newContract) {
        _verifyPayload(payloads);
        (bool isGifted, uint256 giftAmount, address giftGiver, bytes32 birthdayMessage)  = _extractPayloads(payloads);
        
        require(giftGiver == msg.sender, "You are not the gift giver");

        bytes memory bytecode = _makeDeployBytecode(payloads);

        assembly {
            let size := mload(bytecode)
            let data := add(bytecode, 0x20)
            newContract := create(0, data, size)
        }

        require(newContract != address(0), "Deployment failed");
        lastBirthdayContract = Birthday(newContract);

        lastBirthdayContract.setBirthdayMessage(giftGiver, birthdayMessage);

        if (isGifted == true) {
            require(msg.value == giftAmount, "Incorrect gift amount");
            lastBirthdayContract.donationGift{value: giftAmount}();
        } else if (msg.value > 0) {
            revert();
        }
    }

    function _makeDeployBytecode(bytes calldata payloads) internal pure returns (bytes memory) {
        bytes memory bytecode = type(Birthday).creationCode;

        bytes memory additionalCode = abi.encodePacked(
            hex"7f", // PUSH32
            payloads[128:160], // birthdayPerson
            hex"6000", // PUSH1 0
            hex"55", // SSTORE
            hex"7f", // PUSH32
            payloads[160:192], // birthYear
            hex"6001", // PUSH1 1
            hex"55", // SSTORE
            hex"7f", // PUSH32
            payloads[192:224], // birthMonth
            hex"6002", // PUSH1 2
            hex"55", // SSTORE
            hex"7f", // PUSH32
            payloads[224:], // birthDay
            hex"6003", // PUSH1 3
            hex"55" // SSTORE
        );

        // For CODECOPY
        bytecode[84] = bytes1(uint8(uint8(bytecode[84]) + additionalCode.length));

        bytecode = abi.encodePacked(
            additionalCode,
            bytecode
        );

        return bytecode;
    }

    function _extractPayloads(bytes calldata payloads) internal pure returns (bool, uint256, address, bytes32) {
        bool isGifted = abi.decode(payloads[0:32], (bool));
        uint256 giftAmount = abi.decode(payloads[32:64], (uint256));
        address giftGiver = abi.decode(payloads[64:96], (address));
        bytes32 birthdayMessage = abi.decode(payloads[96:128], (bytes32));

        return (isGifted, giftAmount, giftGiver, birthdayMessage);
    }

    function _verifyPayload(bytes calldata payloads) internal view {        
        require(msg.data.length == (4 + 32 + 32 + 32*8), "Invalid calldata length");

        uint256 year = abi.decode(payloads[160:192], (uint256));
        uint256 currentYear = 1970 + (block.timestamp / 31556926);
        require(year >= currentYear, "Year must not be in the past");
    }
}
