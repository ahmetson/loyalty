// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Ownable.sol";

// A utility smartcontract that tracks the credential formats
// to transfer between users and companies.
//
// The credentials are composed from two parts.
// First is the schema based on github.com/iden3/claim-schema-vocab/.
// The second part is the type of credential as in Polygon ID. Example: 'KYCAgeCredential'
abstract contract Credential is Ownable {
    // Counter to generate an ID
    uint64 public credentialTypeAmount;

    // Company -> user -> loyalty points
    mapping(uint64 => bytes) public credentialSchemaUrls;
    mapping(uint64 => bytes) public credentialTypes;
    mapping(bytes32 => uint64) public credentialUniqueness; // avoid adding duplicate credentials

    event AddCredential(uint64 indexed credentialId);
    event DeleteCredential(uint64 indexed credentialId);

    modifier validCredentialId(uint64 credentialId) {
        require(credentialId > 0 && credentialId <= credentialTypeAmount, "credential: out of range");
        require(credentialTypes[credentialId].length > 0, "credential: not found");
        _;
    }

    // Schema URL is based on the iden3 schema:
    //
    //
    // The credential type is as it's defined in Polygon ID.
    // For example: 'KYCAgeCredential'
    function addCredential(bytes calldata schemaUrl, bytes calldata credentialType) external onlyOwner {
        require(schemaUrl.length > 0, "empty schema url");
        require(credentialType.length > 0, "empty credential type");

        bytes32 uniqueType = keccak256(credentialType);
        require(credentialUniqueness[uniqueType] == 0, "credential type exists");

        bytes32 uniqueSchemaUrl = keccak256(schemaUrl);
        require(credentialUniqueness[uniqueSchemaUrl] == 0, "credential schema url exists");

        credentialTypeAmount++;
        credentialUniqueness[uniqueType] = credentialTypeAmount;
        credentialUniqueness[uniqueSchemaUrl] = credentialTypeAmount;

        credentialSchemaUrls[credentialTypeAmount] = schemaUrl;
        credentialTypes[credentialTypeAmount] = credentialType;

        emit AddCredential(credentialTypeAmount);
    }

    function deleteCredential(uint64 credentialId) external validCredentialId(credentialId) onlyOwner {
        bytes32 uniqueType = keccak256(credentialTypes[credentialId]);
        bytes32 uniqueSchemaUrl = keccak256(credentialSchemaUrls[credentialId]);

        delete credentialUniqueness[uniqueType];
        delete credentialUniqueness[uniqueSchemaUrl];
        delete credentialSchemaUrls[credentialId];
        delete credentialTypes[credentialId];

        emit DeleteCredential(credentialId);
    }
}
