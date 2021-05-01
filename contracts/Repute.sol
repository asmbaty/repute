// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Repute {

    struct Rating {
        uint128 sum;
        uint128 count;
    }

    struct Invitation {
        address to;
        bool accepted;
        uint8 host_rating;
        uint8 guest_rating;
    }

    /// @dev Store user reputation (rating)
    mapping (address => Rating) private reputation;

    /// @dev Store invitations from users
    mapping (address => Invitation[]) private invitations;
    
    /// @return the rating of the user multiplied by 100 in the range [100, 500]
    ///         or returns 0 if the user has not given any ratings
    function getRating(address _user) public view returns (uint) {
        Rating storage user_rating = reputation[_user];
        return user_rating.sum / user_rating.count;
    }

    function rate(address _ratee, uint8 rating) public {
        require(1 <= rating && rating <= 5, "Rating must be one of these values {1, 2, 3, 4, 5}");
        require(_ratee != address(0), "Ratee address is not valid");

        uint idx_from = _getInvitationIndex(msg.sender, _ratee);
        if(idx_from != invitations[msg.sender].length) {
            _rate(msg.sender, invitations[msg.sender][idx_from], rating, true);
        } else {
            uint idx_to = _getInvitationIndex(_ratee, msg.sender);
            assert(idx_to != invitations[_ratee].length);
            _rate(_ratee, invitations[_ratee][idx_to], rating, false);
        }
    }

    function _rate(address _from, Invitation storage invitation, uint8 rating, bool as_host) private {
        if(as_host) {
            require(invitation.host_rating == 0, "Already rated");
            invitation.host_rating = rating;
        } else {
            require(invitation.guest_rating == 0, "Already rated");
            invitation.guest_rating = rating;
        }

        _checkIfBothUsersRated(_from, invitation);
    }

    function _checkIfBothUsersRated(address _from, Invitation storage invitation) private {
        if(invitation.host_rating != 0 && invitation.guest_rating != 0) {
            Rating storage host_rep = reputation[_from];
            Rating storage guest_rep = reputation[invitation.to];

            host_rep.sum += uint128(100) * uint128(invitation.guest_rating);
            guest_rep.sum += uint128(100) * uint128(invitation.host_rating);

            host_rep.count++;
            guest_rep.count++;

            _removeInvitation(_from, invitation.to);
        }
    }

    function sendInvitation(address _to) public {
        uint idx_from = _getInvitationIndex(msg.sender, _to);
        require(idx_from == invitations[msg.sender].length, "The invitation already exists");

        uint idx_to = _getInvitationIndex(_to, msg.sender);
        require(idx_to == invitations[_to].length, "A reverse invitation already exists");

        invitations[msg.sender].push(Invitation(_to, false, 0, 0));
    }

    function removeInvitation(address _to) public {
        uint idx_from = _getInvitationIndex(msg.sender, _to);
        require(idx_from == invitations[msg.sender].length, "The invitation doesn't exists");
        _removeInvitation(msg.sender, _to);
    }

    function _removeInvitation(address _from, address _to) private {
        uint idx = _getInvitationIndex(_from, _to);
        uint len = invitations[_from].length;
        assert(idx < len);
        assert(len > 0);
        invitations[_from][idx] = invitations[_from][len-1];
        invitations[_from].pop();
    }

    function acceptInvitation(address _from) public {
        uint idx = _getInvitationIndex(_from, msg.sender);
        require(idx != invitations[_from].length, "The invitation doesn't exist");
        require(!invitations[_from][idx].accepted, "The invitation has already accepted");
        invitations[_from][idx].accepted = true;
    }

    function hasAnInvitation(address _from, address _to) public view returns (bool) {
        return _getInvitationIndex(_from, _to) != invitations[_from].length;
    }

    function _getInvitationIndex(address _from, address _to) private view returns (uint) {
        for(uint i=0; i<invitations[_from].length; ++i) {
            if(invitations[_from][i].to == _to) {
                return i;
            }
        }
        return invitations[_from].length;
    }
}
