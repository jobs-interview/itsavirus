// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface INFT {
    /**
     * @dev Safely mints new NFT and transfers it to `to`.
     * @param _to this address will be the owner of the NFT.
     * 
     * Emits a Transfer event
     */
    function safeMint(address _to) external;

    /**
     * @dev Get rarity of NFT list
     * @return string[3]
     * 
     * List of rarity ['Good', 'Normal', 'Bad']
     */
    function getRarityList() external view returns(string[3] memory);

    /**
     * @dev Get rarity drop rate of the NFT
     * @param _name rarity name
     * @return uint8 rarity rate
     * 
     * Rate for Good = 10, Normal = 60, Bad = 30
     * This means the are 10% chance the user get Good rarity
     * 60% chance the user get Normal rarity
     * 30% chance the user get Bad rarity
     */
    function getRarityRate(string memory _name) external view returns(uint8);

    /**
     * @dev Set the NFT token Uri
     * @param _tokenId the token id of NFT that we want to update
     * @param _newTokenUri the URI of NFT
     * 
     * The URI will be CID of the files
     */
    function setTokenUri(uint256 _tokenId, string memory _newTokenUri) external;
}