package com.issrv.radar.controller;

import com.issrv.radar.entity.AnonymousProfile;
import com.issrv.radar.entity.AnonymousProfileTag;
import com.issrv.radar.repository.AnonymousProfileRepository;
import com.issrv.radar.repository.AnonymousProfileTagRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/anonymous-profiles")
public class AnonymousProfileController {
    private final AnonymousProfileRepository profiles;
    private final AnonymousProfileTagRepository tags;

    public AnonymousProfileController(AnonymousProfileRepository profiles, AnonymousProfileTagRepository tags) {
        this.profiles = profiles;
        this.tags = tags;
    }

    // 创建或更新：档案字段与标签集合整体覆盖
    @PostMapping
    @Transactional
    public ProfileView upsert(@Valid @RequestBody ProfileInput input) {
        AnonymousProfile profile = profiles.findByDeviceToken(input.deviceToken()).orElseGet(() -> {
            AnonymousProfile created = new AnonymousProfile();
            created.setDeviceToken(input.deviceToken());
            return created;
        });
        profile.setZipCode(blankToNull(input.zipCode()));
        profile.setLatitude(input.latitude());
        profile.setLongitude(input.longitude());
        profile = profiles.save(profile);

        tags.deleteByProfileId(profile.getId());
        tags.flush();
        if (input.tags() != null) {
            Map<String, TagInput> distinct = new LinkedHashMap<>();
            input.tags().forEach(t -> distinct.putIfAbsent(t.tagName().trim(), t));
            for (TagInput t : distinct.values()) {
                AnonymousProfileTag tag = new AnonymousProfileTag();
                tag.setProfileId(profile.getId());
                tag.setTagName(t.tagName().trim());
                tag.setTagCategory(t.tagCategory().trim());
                tags.save(tag);
            }
        }
        return view(profile);
    }

    @GetMapping("/{deviceToken}")
    public ProfileView get(@PathVariable String deviceToken) {
        return view(profiles.findByDeviceToken(deviceToken)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Profile not found")));
    }

    @GetMapping("/{deviceToken}/exists")
    public Map<String, Boolean> exists(@PathVariable String deviceToken) {
        return Map.of("exists", profiles.existsByDeviceToken(deviceToken));
    }

    private ProfileView view(AnonymousProfile p) {
        List<TagView> tagViews = tags.findByProfileIdOrderById(p.getId()).stream()
                .map(t -> new TagView(t.getTagName(), t.getTagCategory())).toList();
        return new ProfileView(p.getDeviceToken(), p.getLatitude(), p.getLongitude(), p.getZipCode(),
                tagViews, p.getCreatedAt() == null ? null : p.getCreatedAt().toString(),
                p.getUpdatedAt() == null ? null : p.getUpdatedAt().toString());
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    public record TagInput(@NotBlank @Size(max = 50) String tagName,
                           @NotBlank @Size(max = 50) String tagCategory) {
    }

    public record ProfileInput(@NotBlank @Size(max = 255) String deviceToken,
                               @DecimalMin("-90") @DecimalMax("90") BigDecimal latitude,
                               @DecimalMin("-180") @DecimalMax("180") BigDecimal longitude,
                               @Pattern(regexp = "^\\s*(\\d{5}(-\\d{4})?)?\\s*$", message = "zipCode must be 5 digits")
                               @Size(max = 10) String zipCode,
                               @Valid List<TagInput> tags) {
    }

    public record TagView(String tagName, String tagCategory) {
    }

    public record ProfileView(String deviceToken, BigDecimal latitude, BigDecimal longitude, String zipCode,
                              List<TagView> tags, String createdAt, String updatedAt) {
    }
}
