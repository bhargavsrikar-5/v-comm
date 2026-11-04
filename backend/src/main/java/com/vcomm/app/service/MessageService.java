package com.vcomm.app.service;

import com.vcomm.app.dto.ConversationResponse;
import com.vcomm.app.dto.MessageRequest;
import com.vcomm.app.model.Message;
import com.vcomm.app.model.User;
import com.vcomm.app.repository.MessageRepository;
import com.vcomm.app.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public MessageService(MessageRepository messageRepository, UserRepository userRepository) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    public Message sendMessage(Long authenticatedSenderId, MessageRequest request) {
        Long receiverId = request.getReceiverId();
        if (authenticatedSenderId.equals(receiverId)) {
            throw new IllegalArgumentException("You cannot send a direct message to yourself.");
        }
        if (!userRepository.existsById(receiverId)) {
            throw new IllegalArgumentException("The selected recipient does not exist.");
        }
        Message message = new Message(authenticatedSenderId, receiverId, request.getContent());
        return messageRepository.save(message);
    }

    @Transactional
    public List<Message> getChatHistory(Long authenticatedUserId, Long otherUserId) {
        if (authenticatedUserId.equals(otherUserId) || !userRepository.existsById(otherUserId)) {
            throw new IllegalArgumentException("The selected conversation does not exist.");
        }
        messageRepository.markMessagesAsRead(otherUserId, authenticatedUserId);
        return messageRepository.findChatHistory(authenticatedUserId, otherUserId);
    }

    public List<ConversationResponse> getConversations(Long authenticatedUserId) {
        List<Message> allMessages = messageRepository.findAllByUserId(authenticatedUserId);
        Map<Long, Message> latestMessagePerPartner = new LinkedHashMap<>();

        for (Message message : allMessages) {
            Long partnerId = message.getSenderId().equals(authenticatedUserId)
                    ? message.getReceiverId() : message.getSenderId();
            latestMessagePerPartner.putIfAbsent(partnerId, message);
        }

        List<ConversationResponse> conversations = new ArrayList<>();
        for (Map.Entry<Long, Message> entry : latestMessagePerPartner.entrySet()) {
            Long partnerId = entry.getKey();
            Message latestMessage = entry.getValue();
            Optional<User> partner = userRepository.findById(partnerId);
            if (partner.isPresent()) {
                long unread = messageRepository.countUnreadMessages(partnerId, authenticatedUserId);
                conversations.add(new ConversationResponse(
                        partner.get(), latestMessage.getContent(), latestMessage.getSentAt(), unread));
            }
        }
        return conversations;
    }
}
