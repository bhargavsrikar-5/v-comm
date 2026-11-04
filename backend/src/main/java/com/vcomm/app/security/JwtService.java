package com.vcomm.app.security;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vcomm.app.model.User;
import com.vcomm.app.model.UserRole;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;
import java.util.Map;

/** Minimal HS256 JWT issuer/verifier for this stateless API. */
@Service
public class JwtService {
    private static final String ISSUER = "vcomm-api";
    private static final String ALGORITHM = "HmacSHA256";
    private static final Base64.Encoder URL_ENCODER = Base64.getUrlEncoder().withoutPadding();
    private static final Base64.Decoder URL_DECODER = Base64.getUrlDecoder();

    private final ObjectMapper objectMapper;
    private final byte[] secret;
    private final long expirationSeconds;

    public JwtService(
            ObjectMapper objectMapper,
            @Value("${vcomm.security.jwt-secret:}") String secret,
            @Value("${vcomm.security.jwt-expiration-seconds:43200}") long expirationSeconds) {
        this.objectMapper = objectMapper;
        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException("JWT_SECRET must be configured with at least 32 UTF-8 bytes.");
        }
        if (expirationSeconds < 300 || expirationSeconds > 604800) {
            throw new IllegalStateException("JWT expiration must be between 300 and 604800 seconds.");
        }
        this.secret = secret.getBytes(StandardCharsets.UTF_8);
        this.expirationSeconds = expirationSeconds;
    }

    public String issueToken(User user) {
        try {
            Instant now = Instant.now();
            Map<String, Object> header = Map.of("alg", "HS256", "typ", "JWT");
            Map<String, Object> payload = Map.of(
                    "iss", ISSUER,
                    "sub", user.getId().toString(),
                    "email", user.getEmail(),
                    "role", user.getRole().name(),
                    "iat", now.getEpochSecond(),
                    "exp", now.plusSeconds(expirationSeconds).getEpochSecond());

            String encodedHeader = URL_ENCODER.encodeToString(objectMapper.writeValueAsBytes(header));
            String encodedPayload = URL_ENCODER.encodeToString(objectMapper.writeValueAsBytes(payload));
            String unsignedToken = encodedHeader + "." + encodedPayload;
            String signature = URL_ENCODER.encodeToString(sign(unsignedToken));
            return unsignedToken + "." + signature;
        } catch (Exception exception) {
            throw new IllegalStateException("Unable to issue access token.", exception);
        }
    }

    public VCommPrincipal verifyToken(String token) {
        try {
            String[] parts = token.split("\\.", -1);
            if (parts.length != 3) {
                throw new IllegalArgumentException("Malformed bearer token.");
            }

            String unsignedToken = parts[0] + "." + parts[1];
            byte[] providedSignature = URL_DECODER.decode(parts[2]);
            byte[] expectedSignature = sign(unsignedToken);
            if (!MessageDigest.isEqual(expectedSignature, providedSignature)) {
                throw new IllegalArgumentException("Invalid bearer token signature.");
            }

            Map<String, Object> header = objectMapper.readValue(URL_DECODER.decode(parts[0]), new TypeReference<>() { });
            if (!"HS256".equals(header.get("alg")) || !"JWT".equals(header.get("typ"))) {
                throw new IllegalArgumentException("Unsupported token algorithm.");
            }

            Map<String, Object> claims = objectMapper.readValue(URL_DECODER.decode(parts[1]), new TypeReference<>() { });
            if (!ISSUER.equals(claims.get("iss"))) {
                throw new IllegalArgumentException("Invalid token issuer.");
            }
            long expiresAt = ((Number) claims.get("exp")).longValue();
            if (Instant.now().getEpochSecond() >= expiresAt) {
                throw new IllegalArgumentException("Bearer token has expired.");
            }
            long issuedAt = ((Number) claims.get("iat")).longValue();
            if (issuedAt > Instant.now().plusSeconds(60).getEpochSecond()) {
                throw new IllegalArgumentException("Bearer token issued in the future.");
            }

            Long userId = Long.valueOf(String.valueOf(claims.get("sub")));
            String email = String.valueOf(claims.get("email"));
            UserRole role = UserRole.valueOf(String.valueOf(claims.get("role")));
            if (userId <= 0 || email.isBlank()) {
                throw new IllegalArgumentException("Invalid token subject.");
            }
            return new VCommPrincipal(userId, email, role);
        } catch (Exception exception) {
            throw new IllegalArgumentException("Invalid or expired bearer token.", exception);
        }
    }

    public long getExpirationSeconds() {
        return expirationSeconds;
    }

    private byte[] sign(String value) throws GeneralSecurityException {
        Mac mac = Mac.getInstance(ALGORITHM);
        mac.init(new SecretKeySpec(secret, ALGORITHM));
        return mac.doFinal(value.getBytes(StandardCharsets.US_ASCII));
    }
}
