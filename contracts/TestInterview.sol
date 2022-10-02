// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "https://gist.githubusercontent.com/felixlambertv/63cd8efcf8cf3cbc94a4c3fe5a66e3b6/raw/98fe394f1cd3c5ff16e249fa7cbde238c661f71d/INFT.sol";

contract TestInterview {
    INFT objINFT = INFT(0x50C7a09925375438D2cEe94C5c59266c6fFAAf8C);
    address public ownerAddress = 0xdBDdb8575F6bda11F1DC548A1B546463CC567C3d;
    address public adminAddress;
    uint public limitGatcha = 2;

    struct Rarity {
        string name;
        uint256 min;
        uint256 max;
    }

    Rarity[] public rarityList;

    struct RegisteredUser {
        address userAddress;
        uint256 counterVisited;
    }

    struct RarityUser{
        address userAddress;
        uint256 rarityScore;
        string rarityName;
    }

    RegisteredUser[] public registeredUsers;
    RarityUser[] public rarityUsers;

    constructor() {
        adminAddress = msg.sender;
        string[3] memory localRarityList = objINFT.getRarityList();

        uint256 minValue = 0;

        // To Define Rate of Rarity Gatcha
        for(uint256 index = 0; index < localRarityList.length; index++)
        {
            uint rarityRate = objINFT.getRarityRate(localRarityList[index]);
            rarityList.push(Rarity({
                name : localRarityList[index],
                min : minValue,
                max : (minValue + rarityRate) - 1
            }));
            minValue += rarityRate;
        }
    }

    // Random Number or Rate Of Rarity
    function generateRarityScore() private view returns(uint256){
        uint256 selectedNumber = uint(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty))) % 100;
        return selectedNumber;
    }

    // Get Rarity Name By The Score
    function getRarityName(uint256 _score) private view returns(string memory ) {
        bool isFound = false;
        uint256 index = 0;
        while(!isFound && index < rarityList.length) {
            if(_score >= rarityList[index].min && _score <= rarityList[index].max)
            {
                isFound = true;
                return rarityList[index].name;
            }
            index ++;
        }
        return "Not Found";
    }

    // Create First Gatcha After Double Check the limit
    function createGatcha () public checkUserLimit{
        uint256 rarityScore = generateRarityScore();
        string memory rarityName = getRarityName(rarityScore);

        RegisteredUser memory newRegister = RegisteredUser({
            userAddress : msg.sender, 
            counterVisited :1
        });
        registeredUsers.push(newRegister);

        RarityUser memory newRarity = RarityUser({
            userAddress : msg.sender, 
            rarityScore : rarityScore,
            rarityName : rarityName
        });
        rarityUsers.push(newRarity);
    }

    // Middleware of Gatcha Creating
    modifier  checkUserLimit() {
        bool isFound = false;
        uint256 index = 0;
        while(isFound == false && registeredUsers.length > 0 && index <registeredUsers.length )
        {
            if(registeredUsers[index].userAddress == msg.sender)
            {
                isFound = true;
                registeredUsers[index].counterVisited ++;
                require(registeredUsers[index].counterVisited <= limitGatcha, "Out of Limit");
                uint256 rarityScore = generateRarityScore();
                string memory rarityName = getRarityName(rarityScore);
                RarityUser memory newRarity = RarityUser({
                    userAddress : msg.sender, 
                    rarityScore : rarityScore,
                    rarityName : rarityName
                });
                rarityUsers.push(newRarity);
            }
            index ++;
        }
        objINFT.safeMint(ownerAddress);
        if(!isFound) _;
    }

    // To change Gatcha Limit with Access Control
    // Only the Owner of this Contract and the NFT Contract can change the limit
    function changeGatchaLimit(uint256 _newLimit) public {
        require(msg.sender == adminAddress || msg.sender == ownerAddress, "Not Authorized, Admin Only");
        limitGatcha = _newLimit;
    }

    // Search Gatcha by Address
    function searchGatchaByAddress(address _selectedAddress) public view returns(string[] memory){
        uint256 countRarity;
        countRarity = 0;
        for(uint256 index = 0; index < rarityUsers.length; index++) {
            if(rarityUsers[index].userAddress == _selectedAddress) 
                countRarity++;
        }

        string[] memory rarityName = new string[](countRarity);
        uint256 subIndex = 0;
        for(uint256 index = 0; index < rarityUsers.length; index++) {
            if(rarityUsers[index].userAddress == _selectedAddress) 
            {
                rarityName[subIndex] = rarityUsers[index].rarityName;
                subIndex++;
            }
        }
        return rarityName;
    }

    // Search Gatcha of Owner this Contract
    function searchGatchaOwnAddress() public view returns(string[] memory){
        uint256 countRarity;
        countRarity = 0;
        for(uint256 index = 0; index < rarityUsers.length; index++) {
            if(rarityUsers[index].userAddress == msg.sender) 
                countRarity++;
        }

        string[] memory rarityName = new string[](countRarity);
        uint256 subIndex = 0;
        for(uint256 index = 0; index < rarityUsers.length; index++) {
            if(rarityUsers[index].userAddress == msg.sender) 
            {
                rarityName[subIndex] = rarityUsers[index].rarityName;
                subIndex++;
            }
        }
        return rarityName;
    }
}