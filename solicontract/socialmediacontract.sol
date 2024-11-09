// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniSocial {
    struct Post {
        string message;
        address author;
        uint timestamp;
        uint likeCount;
        uint dislikeCount;
        uint lastModified;
    }
    

    Post[] public posts;
    mapping(uint => mapping(address => bool)) private postLikes;
    mapping(uint => mapping(address => bool)) private postDislikes;

    // Event to notify when a post is created
    event PostCreated(uint postId, address author, string message, uint timestamp);
    event PostUpdated(uint postId, string newMessage, uint lastModified);
    event PostLiked(uint postId, address user, uint likeCount);
    event PostDisliked(uint postId, address user, uint dislikeCount);

    function publishPost(string memory _message) public {
        Post memory newPost = Post({
            message: _message,
            author: msg.sender,
            timestamp: block.timestamp,
            likeCount: 0,
            dislikeCount: 0,
            lastModified: 0
        });
        posts.push(newPost);
        emit PostCreated(posts.length - 1, msg.sender, _message, block.timestamp);
    }

    function getPost(uint index) public view returns (string memory, address, uint, uint, uint, uint) {
        require(index < posts.length, "Index invalide");
        Post memory post = posts[index];
        return (post.message, post.author, post.timestamp, post.likeCount, post.dislikeCount, post.lastModified);
    }

    function likePost(uint postId) public {
        require(postId < posts.length, "Index invalide");
        require(!postLikes[postId][msg.sender], "Already liked");

        if (postDislikes[postId][msg.sender]) {
            postDislikes[postId][msg.sender] = false;
            posts[postId].dislikeCount--;
        }
        postLikes[postId][msg.sender] = true;
        posts[postId].likeCount++;
        emit PostLiked(postId, msg.sender, posts[postId].likeCount);
    }

    function dislikePost(uint postId) public {
        require(postId < posts.length, "Index invalide");
        require(!postDislikes[postId][msg.sender], "Already disliked");

        if (postLikes[postId][msg.sender]) {
            postLikes[postId][msg.sender] = false;
            posts[postId].likeCount--;
        }
        postDislikes[postId][msg.sender] = true;
        posts[postId].dislikeCount++;
        emit PostDisliked(postId, msg.sender, posts[postId].dislikeCount);
    }

    function editPost(uint postId, string memory newMessage) public {
        require(postId < posts.length, "Index invalide");
        require(posts[postId].author == msg.sender, "Only the author can edit this post");

        posts[postId].message = newMessage;
        posts[postId].lastModified = block.timestamp;
        emit PostUpdated(postId, newMessage, block.timestamp);
    }

    function getTotalPosts() public view returns (uint) {
        return posts.length;
    }
}
