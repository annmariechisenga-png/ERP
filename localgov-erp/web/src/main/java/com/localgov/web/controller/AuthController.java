package com.localgov.web.controller;

import com.localgov.web.dashboard.DashboardIdentityService;
import com.localgov.web.security.JwtService;
import com.localgov.web.security.dto.CurrentUserResponse;
import com.localgov.web.security.dto.LoginRequest;
import com.localgov.web.security.dto.LoginResponse;
import jakarta.validation.Valid;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final DashboardIdentityService dashboardIdentityService;
    private final com.localgov.web.security.MfaService mfaService;

    public AuthController(
            AuthenticationManager authenticationManager,
            JwtService jwtService,
            DashboardIdentityService dashboardIdentityService,
            com.localgov.web.security.MfaService mfaService
    ) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.dashboardIdentityService = dashboardIdentityService;
        this.mfaService = mfaService;
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .toList();

        if (mfaService.isMfaEnabled(userDetails.getUsername())
                && !mfaService.verifyCode(userDetails.getUsername(), request.mfaCode())) {
            return new LoginResponse(
                    null,
                    "Bearer",
                    jwtService.getExpirationMillis(),
                    userDetails.getUsername(),
                    roles,
                    dashboardIdentityService.resolveIdentity(userDetails.getUsername()),
                    true,
                    "MFA verification required. Provide the current authenticator code to complete sign-in."
            );
        }

        String token = jwtService.generateToken(userDetails);
        mfaService.recordSuccessfulLogin(userDetails.getUsername());

        return new LoginResponse(
                token,
                "Bearer",
                jwtService.getExpirationMillis(),
                userDetails.getUsername(),
                roles,
                dashboardIdentityService.resolveIdentity(userDetails.getUsername()),
                false,
                "Authentication successful."
        );
    }

    @GetMapping("/me")
    public CurrentUserResponse currentUser(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .toList();

        return new CurrentUserResponse(
                userDetails.getUsername(),
                roles,
                dashboardIdentityService.resolveIdentity(userDetails.getUsername()),
                mfaService.isMfaEnabled(userDetails.getUsername())
        );
    }
}
