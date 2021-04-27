// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Repute {

    struct Rating {
        uint128 sum;
        uint128 count;
    }

    mapping (address => Rating) private reputation;
    
    function getRating(address _user) public view returns (uint) {
        Rating storage user_rating = reputation[_user];
        return user_rating.sum / user_rating.count;
    }

    function Rate(address _ratee, uint128 rating) public {
        require(1 <= rating && rating <= 5);
        rating *= 100; // we expect two floating numbers
        Rating storage user_rating = reputation[_ratee];
        user_rating.sum += rating;
        user_rating.count++;
    }
}
