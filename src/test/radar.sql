/*
 Navicat Premium Data Transfer

 Source Server         : local
 Source Server Type    : MySQL
 Source Server Version : 80403 (8.4.3)
 Source Host           : localhost:3306
 Source Schema         : radar

 Target Server Type    : MySQL
 Target Server Version : 80403 (8.4.3)
 File Encoding         : 65001

 Date: 07/11/2026 04:24:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for age_tag_config
-- ----------------------------
DROP TABLE IF EXISTS `age_tag_config`;
CREATE TABLE `age_tag_config`  (
  `tag_id` bigint UNSIGNED NOT NULL COMMENT '关联 tags.id',
  `min_age` tinyint UNSIGNED NOT NULL COMMENT '适用年龄下限，单位：周岁',
  `max_age` tinyint UNSIGNED NOT NULL COMMENT '适用年龄上限，单位：周岁',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`tag_id`) USING BTREE,
  INDEX `idx_age_range`(`min_age` ASC, `max_age` ASC) USING BTREE,
  CONSTRAINT `fk_age_tag_config_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `chk_age_range` CHECK ((`min_age` >= 0) and (`max_age` >= `min_age`))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '年龄标签的专属配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of age_tag_config
-- ----------------------------
INSERT INTO `age_tag_config` VALUES (1, 0, 0, '2026-10-30 03:29:57', '2026-10-30 03:32:56');
INSERT INTO `age_tag_config` VALUES (2, 1, 10, '2026-10-30 03:29:57', '2026-10-30 03:29:57');
INSERT INTO `age_tag_config` VALUES (3, 11, 18, '2026-10-30 03:29:57', '2026-10-30 03:29:57');

-- ----------------------------
-- Table structure for anonymous_subscriptions
-- ----------------------------
DROP TABLE IF EXISTS `anonymous_subscriptions`;
CREATE TABLE `anonymous_subscriptions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `device_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ukey_token_tag`(`device_token` ASC, `tag_name` ASC) USING BTREE,
  INDEX `idx_tag`(`tag_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of anonymous_subscriptions
-- ----------------------------

-- ----------------------------
-- Table structure for crawl_sources
-- ----------------------------
DROP TABLE IF EXISTS `crawl_sources`;
CREATE TABLE `crawl_sources`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '数据源名称，如 Princeton Library, Terhune Orchards',
  `target_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '需要抓取的具体活动列表网页URL',
  `region_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属地区/小镇，如 Princeton, West Windsor, Lawrenceville',
  `location_geo` point NULL COMMENT '地址坐标，假设活动和数据源所在地址是一致的',
  `default_indoor_outdoor` enum('Indoor','Outdoor','Unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Unknown',
  `county_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'Mercer' COMMENT '所属郡，默认新泽西 Mercer County',
  `source_type` enum('Library','Farm','Township','Park','Commercial','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'Other' COMMENT '数据源类型',
  `page_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'static' COMMENT '翻页类型: static(不翻页), load_more(加载更多), next_button(下一页/天箭头)',
  `max_pages` int NULL DEFAULT 1 COMMENT '最大翻页/切换天数限制',
  `next_selector` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '翻页按钮的 CSS 选择器/定位符',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用抓取：1-启用，0-停用',
  `last_crawled_at` datetime NULL DEFAULT NULL COMMENT '上一次成功抓取的时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '爬虫智能抓取目标源配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of crawl_sources
-- ----------------------------
INSERT INTO `crawl_sources` VALUES (1, 'Princeton Public Library Kids', 'https://princetonlibrary.libnet.info/events?a=Kids', 'Princeton', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'Mercer', 'Library', 'next_button', 3, 'role=button[name=\"Next day\"]', 0, '2026-10-30 03:59:59', '2026-10-28 22:38:32', '2026-11-04 00:43:44');
INSERT INTO `crawl_sources` VALUES (5, 'Princeton Public Library Teens', 'https://princetonlibrary.libnet.info/events?a=Teens', 'Princeton', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'Mercer', 'Library', 'next_button', 5, 'role=button[name=\"Next day\"]', 0, '2026-11-03 03:38:09', '2026-10-30 03:49:32', '2026-11-04 00:43:51');
INSERT INTO `crawl_sources` VALUES (6, 'Terhune Orchards', 'https://www.terhuneorchards.com/events-at-a-glance/', 'West Windsor', ST_GeomFromText('POINT(-74.6914 40.3589)'), 'Outdoor', 'Mercer', 'Farm', 'static', 1, NULL, 0, '2026-11-03 11:56:25', '2026-11-03 06:25:46', '2026-11-05 05:20:48');
INSERT INTO `crawl_sources` VALUES (7, 'West Windsor Voice', 'https://westwindsorvoices.com/West%20Windsor/Events', 'West Windsor', NULL, 'Unknown', 'Mercer', 'Other', 'static', 1, NULL, 0, '2026-11-02 18:19:45', '2026-11-03 07:09:26', '2026-11-04 00:47:55');
INSERT INTO `crawl_sources` VALUES (8, 'Abbott Marshlands', 'https://abbottmarshlands.org/event-calendar-list/', 'Hamilton', NULL, 'Outdoor', 'Mercer', 'Park', 'next_button', 3, 'a.tribe-events-c-nav__next', 1, '2026-11-04 16:26:13', '2026-11-05 05:20:46', '2026-11-05 05:26:13');

-- ----------------------------
-- Table structure for event_image
-- ----------------------------
DROP TABLE IF EXISTS `event_image`;
CREATE TABLE `event_image`  (
  `event_id` int NOT NULL,
  `image_id` bigint UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`event_id`) USING BTREE,
  INDEX `idx_image_id`(`image_id` ASC) USING BTREE,
  CONSTRAINT `fk_event_type_tags_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_event_type_tags_image` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of event_image
-- ----------------------------

-- ----------------------------
-- Table structure for event_tags
-- ----------------------------
DROP TABLE IF EXISTS `event_tags`;
CREATE TABLE `event_tags`  (
  `event_id` int NOT NULL COMMENT '关联events.id',
  `tag_id` bigint UNSIGNED NOT NULL COMMENT '关联tags.id',
  `rule_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '命中的规则ID，人工添加时可为空',
  `tag_source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'rule' COMMENT '标签来源：rule、manual、ai_reviewed',
  `confidence` decimal(5, 4) NULL DEFAULT NULL COMMENT '置信度，范围0到1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`, `tag_id`) USING BTREE,
  INDEX `idx_tag_event`(`tag_id` ASC, `event_id` ASC) USING BTREE,
  INDEX `idx_rule_id`(`rule_id` ASC) USING BTREE,
  CONSTRAINT `fk_event_tags_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_event_tags_rule` FOREIGN KEY (`rule_id`) REFERENCES `tag_rules` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_event_tags_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of event_tags
-- ----------------------------
INSERT INTO `event_tags` VALUES (29, 2, NULL, 'rule', NULL, '2026-10-30 04:00:16');
INSERT INTO `event_tags` VALUES (30, 2, NULL, 'rule', NULL, '2026-10-30 04:00:16');
INSERT INTO `event_tags` VALUES (31, 2, NULL, 'rule', NULL, '2026-10-30 04:00:16');
INSERT INTO `event_tags` VALUES (32, 2, NULL, 'rule', NULL, '2026-10-30 04:00:16');
INSERT INTO `event_tags` VALUES (33, 2, NULL, 'rule', NULL, '2026-10-30 04:39:31');
INSERT INTO `event_tags` VALUES (33, 3, NULL, 'rule', NULL, '2026-10-30 04:39:31');
INSERT INTO `event_tags` VALUES (34, 3, NULL, 'rule', NULL, '2026-10-30 04:39:31');
INSERT INTO `event_tags` VALUES (35, 3, NULL, 'rule', NULL, '2026-10-30 04:39:31');
INSERT INTO `event_tags` VALUES (36, 2, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (36, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (36, 5, 19, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (37, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (38, 2, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (38, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (38, 5, 19, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (39, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (40, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (41, 2, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (41, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (41, 5, 19, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (42, 2, NULL, 'rule', NULL, '2026-10-30 04:27:45');
INSERT INTO `event_tags` VALUES (43, 2, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (43, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (43, 7, 18, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (44, 2, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (44, 3, NULL, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (44, 7, 18, 'rule', NULL, '2026-11-03 03:38:19');
INSERT INTO `event_tags` VALUES (50, 2, 31, 'rule', NULL, '2026-11-03 07:21:19');
INSERT INTO `event_tags` VALUES (55, 11, 24, 'rule', NULL, '2026-11-03 07:21:19');
INSERT INTO `event_tags` VALUES (59, 6, 16, 'rule', NULL, '2026-11-03 07:21:19');
INSERT INTO `event_tags` VALUES (60, 6, 16, 'rule', NULL, '2026-11-03 07:21:19');
INSERT INTO `event_tags` VALUES (60, 11, 24, 'rule', NULL, '2026-11-03 07:21:19');
INSERT INTO `event_tags` VALUES (61, 2, 33, 'rule', NULL, '2026-11-04 00:56:33');
INSERT INTO `event_tags` VALUES (62, 2, 33, 'rule', NULL, '2026-11-04 00:56:33');
INSERT INTO `event_tags` VALUES (63, 2, 33, 'rule', NULL, '2026-11-04 00:56:33');
INSERT INTO `event_tags` VALUES (69, 2, 31, 'rule', NULL, '2026-11-05 05:21:26');
INSERT INTO `event_tags` VALUES (70, 2, 31, 'rule', NULL, '2026-11-05 05:21:26');
INSERT INTO `event_tags` VALUES (74, 8, 23, 'rule', NULL, '2026-11-05 05:26:54');
INSERT INTO `event_tags` VALUES (76, 2, 33, 'rule', NULL, '2026-11-05 05:26:54');
INSERT INTO `event_tags` VALUES (77, 2, 33, 'rule', NULL, '2026-11-05 05:26:54');

-- ----------------------------
-- Table structure for events
-- ----------------------------
DROP TABLE IF EXISTS `events`;
CREATE TABLE `events`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_id` int NULL DEFAULT NULL COMMENT '数据源ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动名称',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `location_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地点名称(如 Terhune Orchards)',
  `location_geo` point NULL COMMENT '空间几何字段，存储经纬度(X=经度, Y=纬度)',
  `indoor_outdoor` enum('Indoor','Outdoor','Unknown') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'Unknown',
  `booking_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '抢位或官网链接',
  `parent_tips` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成的硬核避坑指南',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of events
-- ----------------------------
INSERT INTO `events` VALUES (29, NULL, 'Kids: Take & Make - Inspired by \"Willy Wonka and the Chocolate Factory\" movie', '2026-10-31 10:00:00', 'Princeton Public Library - 3rd Floor Pop-up Programming Area', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/16847048', 'Stop by the third floor Youth Services Dept. for a take-home maker activity while supplies last.', '2026-10-30 03:38:12');
INSERT INTO `events` VALUES (30, NULL, 'Kids: Saturday Storytime!', '2026-10-31 10:30:00', 'Princeton Public Library - Story Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/14662012', 'This interactive, in-person story time features books, songs, rhymes, fingerplays and movement for children 2 years and up, accompanied by an adult. Registration is not required.', '2026-10-30 03:38:12');
INSERT INTO `events` VALUES (31, NULL, 'Kids: Russian Storytime', '2026-11-01 14:30:00', 'Princeton Public Library - Story Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17381904', 'Storytime in Russian for children and their caregivers. Intended for children ages 2 and up who have proficiency in Russian.', '2026-10-30 03:38:12');
INSERT INTO `events` VALUES (32, NULL, 'Kids: Russian Book Club', '2026-11-01 15:00:00', 'Princeton Public Library - Story Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17381860', 'Join us for readings in Russian followed by discussion. Intended for children in kindergarten to fourth grade. Participants should have proficiency in Russian.', '2026-10-30 03:38:12');
INSERT INTO `events` VALUES (33, NULL, 'Kids & Teens: Homework Help', '2026-11-02 15:30:00', 'Princeton Public Library - CoLab Space', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', NULL, 'Registration is not required for this drop-in program.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (34, NULL, 'Catherine Project Weekly Book Discussion Series', '2026-11-02 16:00:00', 'Princeton Public Library - Tower Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17155820', 'Registration is required; please email to request a seat.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (35, NULL, 'Catherine Project Book Discussion Series', '2026-11-02 18:00:00', 'Princeton Public Library - Tower Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17294110', 'Registration is required; please email to request a seat.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (36, NULL, 'Kids & Teens: Homework Help', '2026-11-03 15:30:00', 'Princeton Public Library - CoLab Space', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', NULL, 'Princeton University students provide after-school homework help in all academic subjects to students in elementary through high school. Registration is not required for this drop-in program.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (37, NULL, 'Celebrate Hispanic Heritage/Celebre la Herencia Hispana', '2026-11-03 18:00:00', 'Princeton Public Library - Quiet Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17292364', 'People & Stories presents an eight-week program of literature, discussion and writing in Spanish.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (38, NULL, 'Kids & Teens: Homework Help', '2026-11-04 15:30:00', 'Princeton Public Library - CoLab Space', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', NULL, 'Princeton University students provide after-school homework help in all academic subjects to students in elementary through high school. Registration is not required for this drop-in program.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (39, NULL, 'Journaling Club', '2026-11-04 17:00:00', 'Princeton Public Library - Quiet Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/16862226', 'Anyone motivated by \'The Book of Alchemy: A Creative Practice for an Inspired Life\' by Suleika Jaouad is invited to join this journaling club.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (40, NULL, 'Teens: Bookmark Engraving Workshop', '2026-11-05 15:00:00', 'Princeton Public Library - Myra & Van Williams Spark Lab', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17671545', 'Teens (grades six-12) see a demonstration of our wood engraving pens, then use them to engrave a wooden bookmark. Registration required.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (41, NULL, 'Kids & Teens: Homework Help', '2026-11-05 15:30:00', 'Princeton Public Library - CoLab Space', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', NULL, 'Princeton University students provide after-school homework help in all academic subjects to students in elementary through high school. Registration is not required for this drop-in program.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (42, NULL, 'SCORE Seminar: Starting a Home-Based Business', '2026-11-05 18:30:00', 'Princeton Public Library - Newsroom', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17690716', 'Registration is requested to attend this seminar.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (43, NULL, 'World of Materials Science Day', '2026-11-07 13:00:00', 'Princeton Public Library - Community Room', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17027911', 'At this family-oriented multilingual program, visitors of all ages are invited to explore and play while learning about the world of materials science with Princeton University researchers.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (44, NULL, 'Kids & Teens: Science Saturdays', '2026-11-07 14:00:00', 'Princeton Public Library - Myra & Van Williams Spark Lab', ST_GeomFromText('POINT(-74.6603 40.3517)'), 'Indoor', 'https://princetonlibrary.libnet.info/event/17382023', 'Princeton University scientists present hands-on science activities for students in fifth through eighth grade at this monthly program. Registration required.', '2026-10-30 04:02:23');
INSERT INTO `events` VALUES (45, NULL, 'Todd\'s Tai Chi', '2026-11-04 10:00:00', 'Plainsboro Public Library, Plainsboro, NJ', ST_GeomFromText('POINT(-74.5909234 40.3348819)'), 'Indoor', 'https://westwindsorvoice.town.news/g/west-windsor-nj/e/278040/todds-tai-chi', 'Free and suitable for all levels.', '2026-11-03 06:50:22');
INSERT INTO `events` VALUES (46, NULL, 'Let’s Just Sing! Choral Reading of Brahms Schicksalslied & Nanie & Thompson Frostiana', '2026-11-15 16:00:00', 'Unitarian Universalist Congregation of Princeton, Princeton, NJ', ST_GeomFromText('POINT(-74.6664034 40.3623226)'), 'Indoor', 'https://westwindsorvoice.town.news/g/west-windsor-nj/e/394107/lets-just-sing-choral-reading-brahms-schicksalslied-nanie-thompson', 'Vocal scores provided. Free for students and non-singing guests.', '2026-11-03 06:50:22');
INSERT INTO `events` VALUES (47, NULL, 'FASP Admissions Open House', '2026-12-05 09:30:00', 'French American School of Princeton, Princeton, NJ', ST_GeomFromText('POINT(-74.6597376 40.3496953)'), 'Indoor', 'https://westwindsorvoice.town.news/g/west-windsor-nj/e/385947/fasp-admissions-open-house', 'A chance to meet with teachers and ask questions about the curriculum.', '2026-11-03 06:50:22');
INSERT INTO `events` VALUES (50, NULL, 'AMS East Windsor Toddler Parent Seminar', '2026-11-18 17:00:00', '300D Princeton Hightstown Rd, East Windsor, NJ, United States', ST_GeomFromText('POINT(-74.5381008 40.2729743)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Feast-windsor%2Fams-east-windsor-toddler-parent-seminar%2F100002004130085034/join-us-on-wednesday-november-for-a-toddler-focused-seminar-on-healthy-habits-and-fostering-independ', 'Join us for a toddler-focused seminar on healthy habits and fostering independence during mealtime.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (51, NULL, 'AMS East Windsor Preschool Parent Seminar', '2026-11-19 17:00:00', '300D Princeton Hightstown Rd, East Windsor, NJ, United States', ST_GeomFromText('POINT(-74.5381008 40.2729743)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Feast-windsor%2Fams-east-windsor-preschool-parent-seminar%2F100002004127506321/join-us-on-thursday-november-for-a-', 'Join us for a preschool-focused seminar on positive discipline at home.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (52, NULL, 'Rufus Wainwright at McCarter Theatre Center', '2026-11-19 19:30:00', 'McCarter Theatre Center, 91 University Place, Princeton, NJ 08540, United States', ST_GeomFromText('POINT(-74.6605342 40.3440126)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton%2Frufus-wainwright-at-mccarter-theatre-center%2F2400030578232515/rufus-wainwright-at-mccarter-theatre-center', 'Experience an evening with Rufus Wainwright.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (53, NULL, 'Pet Photos with Santa 🐶😺', '2026-11-23 16:00:00', 'MarketFair, 3535 US Route 1 South, Princeton, NJ, United States', ST_GeomFromText('POINT(-74.6609851 40.3149318)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton%2Fpet-photos-with-santa%2F200030950623318/-pet-photo-night-at-marketfair-bring-', 'Bring your furry family members for festive holiday photos.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (54, NULL, 'Disney\'s Descendants', '2026-11-29 14:00:00', 'Kelsey Theatre At Mercer, 1200 Old Trenton Rd, Princeton Junction, NJ, United States', ST_GeomFromText('POINT(-74.7018981 40.847763)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton-junction%2Fdisneys-descendants%2F2300030769907349/disneys-descendants', 'Enjoy a family-friendly performance of Disney\'s Descendants.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (55, NULL, 'American Repertory Ballet - The Nutcracker', '2026-11-27 14:00:00', 'McCarter Theatre Center, 91 University Place, Princeton, NJ 08540, United States', ST_GeomFromText('POINT(-74.6605342 40.3440126)'), 'Indoor', NULL, 'Experience the magical performance of The Nutcracker.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (56, NULL, 'A Christmas Carol at McCarter Theatre Center', '2026-12-08 14:30:00', 'McCarter Theatre Center, 91 University Place, Princeton, NJ 08540, United States', ST_GeomFromText('POINT(-74.6605342 40.3440126)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton%2Fevent%2F2400027628940018%3Fref%3Deventsearch-event-results/a-christmas-carol-at-mccarter-theatre-center', 'Enjoy the timeless tale of A Christmas Carol.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (57, NULL, 'A Christmas Carol - Relaxed Performance at McCarter Theatre Center', '2026-12-26 10:00:00', 'McCarter Theatre Center, 91 University Place, Princeton, NJ 08540, United States', ST_GeomFromText('POINT(-74.6605342 40.3440126)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton%2Fevent%2F2400030042888713%3Fref%3Deventsearch-event-results/a-christmas-carol-relaxed-performance-at-mccarter-', 'Attend a relaxed performance of the classic A Christmas Carol.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (58, NULL, 'New Jersey Symphony - Handel’s Messiah', '2026-12-18 19:30:00', 'Richardson Auditorium at Princeton University, 68 Nassau St, Princeton, NJ 08542, United States', ST_GeomFromText('POINT(-74.6605839 40.3483733)'), 'Indoor', NULL, 'Experience the magical performance of Handel’s Messiah.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (59, NULL, 'HOW THE GRINCH STOLE CHRISTMAS - INTERACTIVE MOVIE | presented by Theater To Go', '2026-12-13 14:00:00', '1200 Old Trenton Rd, Princeton Junction, NJ, United States', ST_GeomFromText('POINT(-74.6499884 40.2554361)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton-junction%2Fhow-the-grinch-stole-christmas-interactive-movie-presented-by-theater-to-go%2F200030787674816/how-the-grinch-stole-christmas-interactive-movie-', 'Participate in the interactive movie experience of How the Grinch Stole Christmas.', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (60, NULL, 'ELF - INTERACTIVE MOVIE | presented by Theater To Go', '2026-12-12 14:00:00', '1200 Old Trenton Rd, Princeton Junction, NJ, United States', ST_GeomFromText('POINT(-74.6499884 40.2554361)'), 'Indoor', 'https://westwindsorvoices.com/West Windsor/Events/detail/2/https%3A%2F%2Fallevents.in%2Fprinceton-junction%2Felf-interactive-movie-presented-by-theater-to-go%2F200030862230712/elf-interactive-movie-event-sat-dec-', 'Join the ultimate holiday fun with ELF: An Interactive Movie Event!', '2026-11-03 07:21:19');
INSERT INTO `events` VALUES (61, NULL, 'Fall Family Fun Weekends – ENCORE WEEKEND', '2026-11-06 10:00:00', 'Terhune Orchards', ST_GeomFromText('POINT(-74.7250502 40.3318327)'), 'Outdoor', NULL, 'Enjoy the variety of activities available for families.', '2026-11-04 00:56:33');
INSERT INTO `events` VALUES (62, NULL, 'Fall Family Fun Weekends – ENCORE WEEKEND', '2026-11-07 10:00:00', 'Terhune Orchards', ST_GeomFromText('POINT(-74.7250502 40.3318327)'), 'Outdoor', NULL, 'Don\'t miss out on family-friendly activities throughout the day.', '2026-11-04 00:56:33');
INSERT INTO `events` VALUES (63, NULL, 'Fall Family Fun Weekends – ENCORE WEEKEND', '2026-11-08 10:00:00', 'Terhune Orchards', ST_GeomFromText('POINT(-74.7250502 40.3318327)'), 'Outdoor', NULL, 'Ideal event for families to enjoy the fall season.', '2026-11-04 00:56:33');
INSERT INTO `events` VALUES (64, NULL, 'Pie Sampling Weekend', '2026-11-14 11:00:00', 'Terhune Orchards', ST_GeomFromText('POINT(-74.7250502 40.3318327)'), 'Outdoor', NULL, 'Great opportunity for family members to taste various pies.', '2026-11-04 00:56:33');
INSERT INTO `events` VALUES (65, NULL, 'Pie Sampling Weekend', '2026-11-15 11:00:00', 'Terhune Orchards', ST_GeomFromText('POINT(-74.7250502 40.3318327)'), 'Outdoor', NULL, 'A fun weekend for families to enjoy sampling pies together.', '2026-11-04 00:56:33');
INSERT INTO `events` VALUES (66, 8, 'Enjoy an easy walk with our group each Wednesday to explore the beautiful trails of Roebling Park.', '2026-11-04 00:00:00', 'Roebling Park, New Jersey', ST_GeomFromText('POINT(-74.7751049 40.1205876)'), 'Outdoor', NULL, 'Encourage kids to ask questions about nature and share their observations.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (67, 8, 'Explore nature up close, really close! We\'ll guide you through the use of a microscope to examine our collection of insects, butterfly wings, seeds, plus any natural treasures that you bring!', '2026-11-07 00:00:00', NULL, ST_GeomFromText('POINT(-74.7212 40.1873)'), 'Indoor', NULL, 'Prepare to discuss any findings with your kids and encourage curiosity about the natural world.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (68, 8, 'Get creative while helping the environment by turning something used into something exciting and new! This is a Mercer County Park Commission Program. No registration required.', '2026-11-08 00:00:00', NULL, ST_GeomFromText('POINT(-74.7212 40.1873)'), 'Indoor', NULL, 'Bring materials from home that can be repurposed for crafts.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (69, 8, 'Play fun and active group games while learning about the plants and wildlife of the marsh. Parents and kids invited! This is a Mercer County Park Commission Program. No registration required.', '2026-11-15 00:00:00', NULL, ST_GeomFromText('POINT(-74.7212 40.1873)'), 'Outdoor', NULL, 'Join in the games with your kids to make it more enjoyable for the whole family.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (70, 8, 'Bring your little ones to our nature-themed story & play time. We\'ll read nature stories and participate in a fun craft or game, all especially designed for preschoolers.', '2026-11-20 00:00:00', NULL, ST_GeomFromText('POINT(-74.7212 40.1873)'), 'Indoor', NULL, 'Stay engaged and participate in the stories and crafts with your little ones.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (71, 8, 'We\'ll explore the grounds of the nature center for some of the season\'s bountiful leaves and use them to create beautiful art. This is a Mercer County Park Commission Program. No registration required.', '2026-11-22 00:00:00', NULL, ST_GeomFromText('POINT(-74.7212 40.1873)'), 'Outdoor', NULL, 'Bring along a bag for collecting leaves and encourage creative expression during the art activity.', '2026-11-05 05:21:26');
INSERT INTO `events` VALUES (72, 8, 'Wednesday Wonder Walk', '2026-11-04 10:00:00', 'Tulpehaking Nature Center, Hamilton, NJ', ST_GeomFromText('POINT(-74.7254688 40.191064)'), 'Outdoor', 'https://abbottmarshlands.org/event/wednesday-wonder-walk-6/2026-11-04/', 'Meet in the Parking Lot near the Tulpehaking Nature Center by 10 am. In case of inclement weather, cancellations are posted by 9 am on the website.', '2026-11-05 05:26:54');
INSERT INTO `events` VALUES (73, 8, 'First Saturday Wellness Walk – Point Breeze', '2026-11-07 10:00:00', 'Point Breeze, Bordentown, NJ', ST_GeomFromText('POINT(-74.7114508 40.1462685)'), 'Outdoor', 'https://abbottmarshlands.org/event/first-saturday-wellness-walk-point-breeze-4/', 'In case of inclement weather, check the marsh website for cancellations before 9 am on the day of the event.', '2026-11-05 05:26:54');
INSERT INTO `events` VALUES (74, 8, 'FALL CLEANUP IN THE MARSH', '2026-11-07 10:00:00', 'Tulpehaking Nature Center, Hamilton, NJ', ST_GeomFromText('POINT(-74.7254688 40.191064)'), 'Outdoor', 'https://abbottmarshlands.org/event/fall-cleanup-in-the-marsh-2/', 'Wear layered clothing, long pants, closed-toe shoes, and bring a water bottle. Children under the age of 14 must be accompanied by an adult.', '2026-11-05 05:26:54');
INSERT INTO `events` VALUES (75, 8, 'NATURE UNDER THE MICROSCOPE', '2026-11-07 14:00:00', 'Tulpehaking Nature Center, Hamilton, NJ', ST_GeomFromText('POINT(-74.7254688 40.191064)'), 'Indoor', 'https://abbottmarshlands.org/event/nature-under-the-microscope-4/', 'Registration required. Bring any natural treasures you find while exploring outside.', '2026-11-05 05:26:54');
INSERT INTO `events` VALUES (76, 8, 'FAMILY SUNDAYS-UPCYCLE SUNDAYS', '2026-11-08 13:30:00', 'Tulpehaking Nature Center, Hamilton, NJ', ST_GeomFromText('POINT(-74.7254688 40.191064)'), 'Indoor', 'https://abbottmarshlands.org/event/family-sundays-upcycle-sundays-2/', 'No registration required.', '2026-11-05 05:26:54');
INSERT INTO `events` VALUES (77, 8, 'FAMILY SUNDAYS-NATURE GAMES', '2026-11-15 13:30:00', 'Tulpehaking Nature Center, Hamilton, NJ', ST_GeomFromText('POINT(-74.7254688 40.191064)'), 'Indoor', 'https://abbottmarshlands.org/event/family-sundays-nature-games-3/', 'No registration required. Parents and kids are invited to participate together.', '2026-11-05 05:26:54');

ALTER TABLE `events` ADD COLUMN `end_time` datetime NULL DEFAULT NULL AFTER `start_time`;

-- ----------------------------
-- Table structure for exclude_rules
-- ----------------------------
DROP TABLE IF EXISTS `exclude_rules`;
CREATE TABLE `exclude_rules`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `keyword` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `match_type` enum('contains','exact','regex') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'regex',
  `target_field` enum('title','all') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'title',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exclude_rules
-- ----------------------------
INSERT INTO `exclude_rules` VALUES (1, '\\b(wine|winery|wineries|brewery|beer|cocktails?|happy hour|wine trail|mulled wine)\\b', 'regex', 'title', 'Alcohol-related events', 1);

-- ----------------------------
-- Table structure for geocode_cache
-- ----------------------------
DROP TABLE IF EXISTS `geocode_cache`;
CREATE TABLE `geocode_cache`  (
  `normalized_location` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `longitude` decimal(10, 7) NULL DEFAULT NULL,
  `latitude` decimal(10, 7) NULL DEFAULT NULL,
  `searched_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`normalized_location`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of geocode_cache
-- ----------------------------
INSERT INTO `geocode_cache` VALUES ('1200 old trenton rd, nj, united states', -74.6499884, 40.2554361, '2026-11-03 20:03:57');
INSERT INTO `geocode_cache` VALUES ('1200 old trenton rd, princeton junction, nj, united states', NULL, NULL, '2026-11-03 20:02:37');
INSERT INTO `geocode_cache` VALUES ('300d princeton hightstown rd, east windsor, nj 08520', -74.5675775, 40.2877710, '2026-11-03 07:14:25');
INSERT INTO `geocode_cache` VALUES ('300d princeton hightstown rd, east windsor, nj, united states', -74.5381008, 40.2729743, '2026-11-03 07:19:58');
INSERT INTO `geocode_cache` VALUES ('3535 us route 1 south, princeton, nj, united states', NULL, NULL, '2026-11-03 20:01:49');
INSERT INTO `geocode_cache` VALUES ('68 nassau st, princeton, nj 08542, united states', -74.6605839, 40.3483733, '2026-11-03 20:03:41');
INSERT INTO `geocode_cache` VALUES ('91 university place, princeton, nj 08540', -74.6605342, 40.3440126, '2026-11-03 19:51:23');
INSERT INTO `geocode_cache` VALUES ('91 university place, princeton, nj 08540, united states', -74.6605342, 40.3440126, '2026-11-03 20:01:31');
INSERT INTO `geocode_cache` VALUES ('bordentown, nj', -74.7114508, 40.1462685, '2026-11-05 05:26:53');
INSERT INTO `geocode_cache` VALUES ('kelsey theatre at mercer, 1200 old trenton rd, princeton junction, nj, united states', NULL, NULL, '2026-11-03 20:02:21');
INSERT INTO `geocode_cache` VALUES ('kelsey theatre at mercer, nj, united states', NULL, NULL, '2026-11-03 20:02:53');
INSERT INTO `geocode_cache` VALUES ('marketfair, 3535 us route 1 south, princeton, nj, united states', NULL, NULL, '2026-11-03 20:01:33');
INSERT INTO `geocode_cache` VALUES ('marketfair, nj, united states', -74.6609851, 40.3149318, '2026-11-03 20:02:05');
INSERT INTO `geocode_cache` VALUES ('marketfair, princeton, nj 08540', -74.6609851, 40.3149318, '2026-11-03 19:51:53');
INSERT INTO `geocode_cache` VALUES ('mccarter theatre center, 91 university place, princeton, nj 08540, united states', NULL, NULL, '2026-11-03 20:01:01');
INSERT INTO `geocode_cache` VALUES ('nj, united', -74.7018981, 40.8477630, '2026-11-03 20:03:09');
INSERT INTO `geocode_cache` VALUES ('plainsboro', -74.6004341, 40.3334409, '2026-11-03 06:50:05');
INSERT INTO `geocode_cache` VALUES ('plainsboro public library, plainsboro, nj', -74.5909234, 40.3348819, '2026-11-03 07:01:27');
INSERT INTO `geocode_cache` VALUES ('point breeze, bordentown, nj', NULL, NULL, '2026-11-05 05:26:37');
INSERT INTO `geocode_cache` VALUES ('princeton', -74.6597376, 40.3496953, '2026-11-03 06:50:21');
INSERT INTO `geocode_cache` VALUES ('princeton junction, nj', -74.6241189, 40.3159898, '2026-11-03 19:52:36');
INSERT INTO `geocode_cache` VALUES ('princeton, nj', -74.6597376, 40.3496953, '2026-11-03 19:52:20');
INSERT INTO `geocode_cache` VALUES ('richardson auditorium at princeton university, 68 nassau st, princeton, nj 08542, united states', NULL, NULL, '2026-11-03 20:03:25');
INSERT INTO `geocode_cache` VALUES ('roebling park, new jersey', -74.7751049, 40.1205876, '2026-11-05 05:21:26');
INSERT INTO `geocode_cache` VALUES ('terhune orchards', -74.7250502, 40.3318327, '2026-11-04 00:56:33');
INSERT INTO `geocode_cache` VALUES ('tulpehaking nature center, hamilton, nj', -74.7254688, 40.1910640, '2026-11-05 05:26:22');
INSERT INTO `geocode_cache` VALUES ('unitarian universalist congregation of princeton, princeton, nj', -74.6664034, 40.3623226, '2026-11-03 07:01:43');

-- ----------------------------
-- Table structure for images
-- ----------------------------
DROP TABLE IF EXISTS `images`;
CREATE TABLE `images`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `image_url` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `mime_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `width` smallint UNSIGNED NULL DEFAULT NULL,
  `height` smallint UNSIGNED NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_file_name`(`file_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of images
-- ----------------------------

-- ----------------------------
-- Table structure for tag_rules
-- ----------------------------
DROP TABLE IF EXISTS `tag_rules`;
CREATE TABLE `tag_rules`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `tag_id` bigint UNSIGNED NOT NULL COMMENT '关联tags.id',
  `keyword` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '待匹配关键词或短语',
  `rule_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'keyword' COMMENT '规则类型：keyword、regex、age_range',
  `match_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'contains' COMMENT '匹配方式：contains、exact、regex',
  `target_field` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'all' COMMENT '匹配字段：title、description、all等',
  `priority` int NOT NULL DEFAULT 100 COMMENT '规则优先级，数值越小越优先',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tag_keyword_field`(`tag_id` ASC, `keyword` ASC, `target_field` ASC) USING BTREE,
  INDEX `idx_keyword`(`keyword` ASC) USING BTREE,
  INDEX `idx_tag_id`(`tag_id` ASC) USING BTREE,
  INDEX `idx_active_priority`(`is_active` ASC, `priority` ASC) USING BTREE,
  CONSTRAINT `fk_tag_rules_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tag_rules
-- ----------------------------
INSERT INTO `tag_rules` VALUES (16, 6, '\\b(movie|film|screening)s?\\b', 'keyword', 'regex', 'title', 10, 1, '2026-11-03 03:04:57');
INSERT INTO `tag_rules` VALUES (17, 4, '\\b(story\\s?time|storytelling|read[- ]aloud)\\b', 'keyword', 'regex', 'title', 10, 1, '2026-11-03 03:04:57');
INSERT INTO `tag_rules` VALUES (18, 7, '\\b(science|stem|steam|robotics|coding|experiment)s?\\b', 'keyword', 'regex', 'title', 10, 1, '2026-11-03 03:04:57');
INSERT INTO `tag_rules` VALUES (19, 5, '\\b(homework|tutoring|study (hall|help))\\b', 'keyword', 'regex', 'title', 10, 1, '2026-11-03 03:04:57');
INSERT INTO `tag_rules` VALUES (23, 8, '\\b(hik(e|ing)s?|trail hik(e|ing)|nature walks?)\\b', 'keyword', 'regex', 'all', 11, 1, '2026-11-03 03:52:20');
INSERT INTO `tag_rules` VALUES (24, 11, '\\b(danc(e|ing)s?|ballet|hip[- ]hop|tap dance|folk dance)\\b', 'keyword', 'regex', 'all', 11, 1, '2026-11-03 03:52:20');
INSERT INTO `tag_rules` VALUES (25, 9, '\\b(sports?|swim(ming|s)?|soccer|basketball|baseball|softball|football|tennis|volleyball|gymnastics|martial arts|karate|taekwondo|judo|hockey|lacrosse|track and field|badminton|pickleball|ice skating|roller skating|fencing|wrestling)\\b', 'keyword', 'regex', 'all', 11, 1, '2026-11-03 03:52:20');
INSERT INTO `tag_rules` VALUES (26, 10, '\\b(cook(ing|s)?|baking|bake(s|d)?|culinary|kitchen)\\b', 'keyword', 'regex', 'all', 11, 1, '2026-11-03 03:52:20');
INSERT INTO `tag_rules` VALUES (30, 1, '\\b(infants?|bab(?:y|ies))\\b', 'keyword', 'regex', 'all', 12, 1, '2026-11-03 03:55:42');
INSERT INTO `tag_rules` VALUES (31, 2, '\\b(kids?|children|child|toddlers?|preschoolers?)\\b', 'keyword', 'regex', 'all', 12, 1, '2026-11-03 03:55:42');
INSERT INTO `tag_rules` VALUES (32, 3, '\\b(teens?|teenagers?|adolescents?)\\b', 'keyword', 'regex', 'all', 12, 1, '2026-11-03 03:55:42');
INSERT INTO `tag_rules` VALUES (33, 2, '\\b(family|families|kid-friendly|story ?time|puppet|hayrides?|petting zoo|storybook|santa|easter egg|trick[- ]or[- ]treat)\\b', 'keyword', 'regex', 'all', 13, 1, '2026-11-04 00:36:19');

-- ----------------------------
-- Table structure for tag_suggestions
-- ----------------------------
DROP TABLE IF EXISTS `tag_suggestions`;
CREATE TABLE `tag_suggestions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `suggested_tag_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tag_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_new_tag` tinyint(1) NOT NULL DEFAULT 1,
  `keyword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `match_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'contains',
  `target_field` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'title',
  `source_event_id` int NULL DEFAULT NULL,
  `evidence` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `confidence` decimal(3, 2) NULL DEFAULT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_tag_keyword`(`suggested_tag_name` ASC, `keyword` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tag_suggestions
-- ----------------------------
INSERT INTO `tag_suggestions` VALUES (1, 'storytime', 'eventtype', 0, 'literature', 'contains', 'title', 37, 'People & Stories presents an eight-week program of literature, discussion and writing in Spanish.', 0.80, 'rejected', '2026-11-03 03:19:28', NULL);
INSERT INTO `tag_suggestions` VALUES (2, 'homework', 'eventtype', 0, 'writing', 'contains', 'title', 39, 'Anyone motivated by \"The Book of Alchemy: A Creative Practice for an Inspired Life\" by Suleika Jaouad is invited to join this journaling club.', 0.60, 'rejected', '2026-11-03 03:19:28', NULL);
INSERT INTO `tag_suggestions` VALUES (3, 'science', 'eventtype', 0, 'engraving', 'contains', 'title', 40, 'see a demonstration of our wood engraving pens, then use them to engrave a wooden bookmark.', 0.70, 'rejected', '2026-11-03 03:19:28', NULL);
INSERT INTO `tag_suggestions` VALUES (5, 'homework', 'eventtype', 0, 'journaling', 'contains', 'title', 39, 'Anyone motivated by \"The Book of Alchemy: A Creative Practice for an Inspired Life\" by Suleika Jaouad is invited to join this journaling club.', 0.60, 'rejected', '2026-11-03 03:38:22', NULL);
INSERT INTO `tag_suggestions` VALUES (7, 'Dance', 'eventtype', 0, 'Choral Reading', 'contains', 'title', 46, 'Let’s Just Sing! Choral Reading of Brahms Schicksalslied & Nanie & Thompson Frostiana', 0.70, 'pending', '2026-11-03 06:50:24', NULL);
INSERT INTO `tag_suggestions` VALUES (8, 'Sports', 'eventtype', 0, 'Tai Chi', 'contains', 'title', 45, 'Learn and practice Tai Chi.', 0.80, 'pending', '2026-11-03 07:02:02', NULL);
INSERT INTO `tag_suggestions` VALUES (10, 'Homework', 'eventtype', 0, 'Admissions Open House', 'contains', 'title', 47, 'learn how our robust dual-language curriculum develops curiosity and a love of learning', 0.70, 'pending', '2026-11-03 07:02:02', NULL);
INSERT INTO `tag_suggestions` VALUES (11, 'Homework', 'eventtype', 0, 'seminar', 'contains', 'title', 50, 'Join us on Wednesday, November 18 for a Toddler focused Seminar on healthy habits and fostering independence during mealtime', 0.70, 'pending', '2026-11-03 07:21:22', NULL);
INSERT INTO `tag_suggestions` VALUES (13, 'Movie', 'eventtype', 0, 'photos', 'contains', 'title', 53, 'Bring your furry family members to MarketFair for a festive evening of holiday photos!', 0.50, 'pending', '2026-11-03 07:21:22', NULL);
INSERT INTO `tag_suggestions` VALUES (14, 'Movie', 'eventtype', 0, 'Disney\'s Descendants', 'contains', 'title', 54, 'Disney\'s Descendants', 0.90, 'pending', '2026-11-03 07:21:22', NULL);
INSERT INTO `tag_suggestions` VALUES (15, 'Movie', 'eventtype', 0, 'A Christmas Carol', 'contains', 'title', 56, 'A Christmas Carol at McCarter Theatre Center', 0.90, 'pending', '2026-11-03 07:21:22', NULL);
INSERT INTO `tag_suggestions` VALUES (17, 'Hiking', 'eventtype', 0, 'walk', 'contains', 'title', 66, 'Enjoy an easy walk with our group each Wednesday to explore the beautiful trails of Roebling Park.', 0.80, 'pending', '2026-11-05 05:21:30', NULL);
INSERT INTO `tag_suggestions` VALUES (18, 'Science', 'eventtype', 0, 'microscope', 'contains', 'title', 67, 'We\'ll guide you through the use of a microscope to examine our collection of insects, butterfly wings, seeds, plus any natural treasures that you bring!', 0.90, 'pending', '2026-11-05 05:21:30', NULL);
INSERT INTO `tag_suggestions` VALUES (19, 'Storytime', 'eventtype', 0, 'story', 'contains', 'title', 70, 'Bring your little ones to our nature-themed story & play time. We\'ll read nature stories and participate in a fun craft or game, all especially designed for preschoolers.', 0.90, 'pending', '2026-11-05 05:21:30', NULL);
INSERT INTO `tag_suggestions` VALUES (23, 'Cooking', 'eventtype', 0, 'upcycle', 'contains', 'title', 76, 'Get creative while helping the environment by turning something used into something exciting and new!', 0.60, 'pending', '2026-11-05 05:26:57', NULL);
INSERT INTO `tag_suggestions` VALUES (24, 'Sports', 'eventtype', 0, 'games', 'contains', 'title', 77, 'Play fun and active group games while learning about the plants and wildlife of the marsh.', 0.70, 'pending', '2026-11-05 05:26:57', NULL);

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标准标签名称',
  `tag_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签分类：age、activity_type、environment等',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签说明',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tag_name_category`(`tag_name` ASC, `tag_category` ASC) USING BTREE,
  INDEX `idx_tag_category`(`tag_category` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tags
-- ----------------------------
INSERT INTO `tags` VALUES (1, 'Infant', 'age', 'age below 1', 1, '2026-10-30 02:35:00');
INSERT INTO `tags` VALUES (2, 'Kid', 'age', 'age range: 1-10', 1, '2026-10-30 02:35:00');
INSERT INTO `tags` VALUES (3, 'Teenage', 'age', 'age range: 11-18', 1, '2026-10-30 02:35:00');
INSERT INTO `tags` VALUES (4, 'Storytime', 'eventtype', NULL, 1, '2026-10-30 06:11:09');
INSERT INTO `tags` VALUES (5, 'Homework', 'eventtype', NULL, 1, '2026-10-30 06:11:25');
INSERT INTO `tags` VALUES (6, 'Movie', 'eventtype', NULL, 1, '2026-10-30 06:11:33');
INSERT INTO `tags` VALUES (7, 'Science', 'eventtype', NULL, 1, '2026-10-30 06:12:44');
INSERT INTO `tags` VALUES (8, 'Hiking', 'eventtype', NULL, 1, '2026-10-30 06:12:51');
INSERT INTO `tags` VALUES (9, 'Sports', 'eventtype', NULL, 1, '2026-10-30 06:12:58');
INSERT INTO `tags` VALUES (10, 'Cooking', 'eventtype', NULL, 1, '2026-10-30 06:13:10');
INSERT INTO `tags` VALUES (11, 'Dance', 'eventtype', NULL, 1, '2026-11-03 03:49:15');

SET FOREIGN_KEY_CHECKS = 1;
