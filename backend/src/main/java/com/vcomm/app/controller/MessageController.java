package com.vcomm.app.controller;

import com.vcomm.app.dto.ConversationResponse;
import com.vcomm.app.dto.MessageRequest;
import com.vcomm.app.model.Message;
import com.vcomm.app.security.VCommPrincipal;
import com.vcomm.app.service.MessageService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {
    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @PostMapping
    public ResponseEntity<Message> sendMessage(@AuthenticationPrincipal VCommPrincipal principal,
                                                @Valid @RequestBody MessageRequest request) {
        return ResponseEntity.ok(messageService.sendMessage(principal.userId(), request));
    }

    @GetMapping("/history")
    public ResponseEntity<List<Message>> getChatHistory(@AuthenticationPrincipal VCommPrincipal principal,
                                                          @RequestParam Long otherUserId) {
        return ResponseEntity.ok(messageService.getChatHistory(principal.userId(), otherUserId));
    }

    @GetMapping("/conversations")
    public ResponseEntity<List<ConversationResponse>> getConversations(@AuthenticationPrincipal VCommPrincipal principal) {
        return ResponseEntity.ok(messageService.getConversations(principal.userId()));
    }
}
