// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

/**
 * @title Repute: Invite peers to meetings and rate each other afterwards.
 * Build your reputation.
 * @dev The main functionality of this contract is Send/Remove/Accept invites
 * and Rate each other later on
 */
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

    event InvitationSent(address indexed from, address indexed to);
    event InvitationCancelled(address indexed from, address indexed to);
    event InvitationAccepted(address indexed from, address indexed to);
    event RatingUpdated(address indexed ratee);

    /// @dev Store user reputation (rating)
    mapping (address => Rating) private reputation;

    /// @dev Store invitations from users
    mapping (address => Invitation[]) private invitations;
    
    /**
     * @return the rating of the user multiplied by 100 in the range [100, 500]
     *         or returns 0 if the user has not given any ratings
     * @notice Everybody's rating is public
     */
    function getRating(address _user) public view returns (uint128) {
        Rating storage user_rating = reputation[_user];
        if( user_rating.count == 0) {
            return 0;
        }
        return user_rating.sum * 100 / user_rating.count;
    }

    /**
     * @dev Rate your peer
     * @param _ratee The address of peer to give a rating
     * @param _rating Rating is a number from the set {1, 2, 3, 4, 5}
     */
    function rate(address _ratee, uint8 _rating) public {
        require(1 <= _rating && _rating <= 5, "_Rating must be one of these values {1, 2, 3, 4, 5}");
        require(_ratee != address(0), "Ratee address is not valid");

        uint idx_from = _getInvitationIndex(msg.sender, _ratee);
        if(idx_from != invitations[msg.sender].length) {
            _rate(msg.sender, invitations[msg.sender][idx_from], _rating, true);
        } else {
            uint idx_to = _getInvitationIndex(_ratee, msg.sender);
            require(idx_to != invitations[_ratee].length, "Could not find a meeting with the ratee");
            _rate(_ratee, invitations[_ratee][idx_to], _rating, false);
        }
    }

    /// @dev Update rating in the invitation structure
    function _rate(address _from, Invitation storage _invitation, uint8 _rating, bool _as_host) private {
        if(_as_host) {
            require(_invitation.host_rating == 0, "Already rated");
            _invitation.host_rating = _rating;
        } else {
            require(_invitation.guest_rating == 0, "Already rated");
            _invitation.guest_rating = _rating;
        }

        _checkIfBothUsersRated(_from, _invitation);
    }

    /// @dev If both users have rated, add rating to global user ratings
    function _checkIfBothUsersRated(address _from, Invitation storage _invitation) private {
        if(_invitation.host_rating != 0 && _invitation.guest_rating != 0) {
            Rating storage host_rep = reputation[_from];
            Rating storage guest_rep = reputation[_invitation.to];

            host_rep.sum += uint128(_invitation.guest_rating);
            guest_rep.sum += uint128(_invitation.host_rating);

            host_rep.count++;
            guest_rep.count++;

            _removeInvitation(_from, _invitation.to);

            emit RatingUpdated(_from);
            emit RatingUpdated(_invitation.to);
        }
    }

    /**
     * @dev Send meeting invitation to a user
     * @param _to User address
     */
    function sendInvitation(address _to) public {
        require(_to != address(0), "Guest address is not valid");

        uint idx_from = _getInvitationIndex(msg.sender, _to);
        require(idx_from == invitations[msg.sender].length, "The invitation already exists");

        uint idx_to = _getInvitationIndex(_to, msg.sender);
        require(idx_to == invitations[_to].length, "A reverse invitation already exists");

        invitations[msg.sender].push(Invitation(_to, false, 0, 0));
        emit InvitationSent(msg.sender, _to);
    }

    /**
     * @dev Cancel sent invitation if it is not accepted yet
     */
    function cancelInvitation(address _to) public {
        uint idx = _getInvitationIndex(msg.sender, _to);
        require(idx == invitations[msg.sender].length, "The invitation doesn't exists");
        require(!invitations[msg.sender][idx].accepted, "The invitation has already accepted");
        _removeInvitation(msg.sender, _to);
        emit InvitationCancelled(msg.sender, _to);
    }

    /// @dev Remove invitation from the invitations mapping
    function _removeInvitation(address _from, address _to) private {
        uint idx = _getInvitationIndex(_from, _to);
        uint len = invitations[_from].length;
        assert(idx < len);
        assert(len > 0);
        invitations[_from][idx] = invitations[_from][len-1];
        invitations[_from].pop();
    }
    /**
     * @dev Accept invitation
     * @param _from Which invitation to accept
     */
    function acceptInvitation(address _from) public {
        uint idx = _getInvitationIndex(_from, msg.sender);
        require(idx != invitations[_from].length, "The invitation doesn't exist");
        require(!invitations[_from][idx].accepted, "The invitation has already accepted");
        invitations[_from][idx].accepted = true;
        emit InvitationAccepted(_from, msg.sender);
    }

    /// @dev Helper function to get invitation index from invitation
    function _getInvitationIndex(address _from, address _to) private view returns (uint) {
        for(uint i=0; i<invitations[_from].length; ++i) {
            if(invitations[_from][i].to == _to) {
                return i;
            }
        }
        return invitations[_from].length;
    }
}
