CREATE DATABASE IF NOT EXISTS `study`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `study`;

CREATE TABLE IF NOT EXISTS `articles` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键，自增文章 ID',
  `level` tinyint unsigned NOT NULL COMMENT '文章等级：1短句，2长句，3短文，4长文',
  `title` varchar(120) NOT NULL COMMENT '文章标题',
  `chinese_text` text NOT NULL COMMENT '中文原文',
  `english_text` text NOT NULL COMMENT '英文原文',
  `word_count` int unsigned NOT NULL COMMENT '英文单词数量',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_articles_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='文章主表';

INSERT INTO `articles` (`id`, `level`, `title`, `chinese_text`, `english_text`, `word_count`)
WITH RECURSIVE seq AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 50
),
levels AS (
  SELECT 1 AS level_no
  UNION ALL SELECT 2
  UNION ALL SELECT 3
  UNION ALL SELECT 4
),
source_rows AS (
  SELECT
    level_no * 1000 + n AS id,
    level_no AS level,
    CONCAT('Level ', level_no, ' Practice ', LPAD(n, 2, '0')) AS title,
    CASE level_no
      WHEN 1 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN CONCAT('第', n, '题：早晨的天空很蓝。')
        WHEN 1 THEN CONCAT('第', n, '题：她每天读书。')
        WHEN 2 THEN CONCAT('第', n, '题：孩子们在花园里玩。')
        WHEN 3 THEN CONCAT('第', n, '题：请把门打开。')
        WHEN 4 THEN CONCAT('第', n, '题：我的朋友喜欢音乐。')
        WHEN 5 THEN CONCAT('第', n, '题：雨后空气很清新。')
        WHEN 6 THEN CONCAT('第', n, '题：老师微笑着走进教室。')
        WHEN 7 THEN CONCAT('第', n, '题：晚饭已经准备好了。')
        WHEN 8 THEN CONCAT('第', n, '题：这本书很有趣。')
        ELSE CONCAT('第', n, '题：我们明天去公园。')
      END
      WHEN 2 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN CONCAT('第', n, '题：早晨的公交车准时到站，学生们安静地排队上车。')
        WHEN 1 THEN CONCAT('第', n, '题：她在图书馆找到一本有用的书，并认真做了笔记。')
        WHEN 2 THEN CONCAT('第', n, '题：孩子们放学后在操场练习跑步，为运动会做准备。')
        WHEN 3 THEN CONCAT('第', n, '题：如果明天天气晴朗，我们会一起去湖边散步。')
        WHEN 4 THEN CONCAT('第', n, '题：我的朋友正在学习做饭，因为他想照顾家人。')
        WHEN 5 THEN CONCAT('第', n, '题：这家小店虽然不大，但面包新鲜，服务也很热情。')
        WHEN 6 THEN CONCAT('第', n, '题：老师解释完题目后，很多学生终于明白了解题思路。')
        WHEN 7 THEN CONCAT('第', n, '题：晚饭后，父亲关掉电视，陪妹妹练习英语发音。')
        WHEN 8 THEN CONCAT('第', n, '题：这部电影讲述了一个普通人坚持梦想的故事。')
        ELSE CONCAT('第', n, '题：我们计划周末打扫房间，然后整理旧书和衣服。')
      END
      WHEN 3 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN CONCAT('第', n, '篇：清晨，社区里的小路还很安静。李明背着书包走出家门，看到清洁工正在打扫落叶。他放慢脚步，向对方问好。到了学校以后，他把这件小事写进日记，提醒自己尊重每一个认真工作的人。')
        WHEN 1 THEN CONCAT('第', n, '篇：周末下午，安娜和母亲去了附近的市场。她们先买了水果，又挑选了新鲜蔬菜。回家后，安娜帮忙清洗番茄并摆放餐具。晚饭很简单，却让一家人觉得温暖，因为每个人都参与了准备。')
        WHEN 2 THEN CONCAT('第', n, '篇：学校举行阅读分享会时，王老师让每个学生介绍一本喜欢的书。小雅有些紧张，但她提前写好了提纲。轮到她发言时，她慢慢说明故事内容和自己的感受，最后赢得了同学们的掌声。')
        WHEN 3 THEN CONCAT('第', n, '篇：雨下得很大，操场上的比赛被迫推迟。几名学生没有失望，而是留在教室里整理器材。他们检查球拍，擦干篮球，还把名单重新贴好。等天气转晴时，活动很快就顺利开始了。')
        WHEN 4 THEN CONCAT('第', n, '篇：陈叔叔每天骑车上班，路上经过一条河。他喜欢观察河边的变化：春天有新草，夏天有荷花，秋天有落叶，冬天有薄冰。这些平常的景象让他的通勤时间变得安静而愉快。')
        WHEN 5 THEN CONCAT('第', n, '篇：班级准备英语短剧，大家分工合作。有人修改台词，有人准备服装，还有人负责音乐。排练时常会出错，但同学们互相提醒。演出那天，他们没有追求完美，只是尽力把故事讲清楚。')
        WHEN 6 THEN CONCAT('第', n, '篇：奶奶教小林包饺子。开始时，小林总是把馅放得太多，饺子合不上。奶奶没有批评他，只是示范怎样控制分量。练习几次后，小林终于包出了整齐的饺子，也明白耐心很重要。')
        WHEN 7 THEN CONCAT('第', n, '篇：图书馆新开了一个自习区。管理员提醒大家保持安静，并把手机调成静音。许多学生喜欢那里，因为桌子宽敞，灯光柔和。每到考试前，座位很快就会坐满。')
        WHEN 8 THEN CONCAT('第', n, '篇：一次班会课上，老师请大家讨论如何节约用水。同学们提出了很多办法，比如及时关水龙头，用盆接水洗菜，把雨水用于浇花。讨论结束后，班级决定从当天开始记录用水习惯。')
        ELSE CONCAT('第', n, '篇：小镇的火车站重新开放了。第一班车到来时，许多居民站在站台上拍照。老人们想起过去出远门的日子，孩子们则好奇地看着车厢。这个普通的早晨让小镇重新热闹起来。')
      END
      ELSE CASE MOD(n - 1, 10)
        WHEN 0 THEN CONCAT('第', n, '篇：在城市边缘，有一所不大的社区学校。学校没有华丽的大厅，却有一间总是亮着灯的阅览室。每天放学后，学生们会把书包放在角落，围坐在长桌旁阅读。管理员陈老师会根据每个孩子的兴趣推荐书籍。有的孩子喜欢科学故事，有的孩子喜欢历史人物，也有人只想读一本轻松的漫画。陈老师从不催促他们选择更难的内容，因为她相信稳定的阅读习惯比一次读完厚书更重要。一个学期后，很多学生开始主动写读书记录，还把自己喜欢的句子抄在卡片上。阅览室慢慢成了学校里最安静也最有生命力的地方。')
        WHEN 1 THEN CONCAT('第', n, '篇：一个春天的周六，志愿者们来到河边清理垃圾。起初，大家觉得任务很简单，只需要捡起塑料瓶和废纸。可是走近河岸后，他们发现草丛里还藏着破旧的袋子、饮料罐和被泥土盖住的包装盒。队长把人员分成三组，一组负责分类，一组负责记录，另一组负责联系清运车辆。两个小时后，河岸看起来整洁了许多。更重要的是，附近居民看到他们的行动后，也开始讨论如何减少一次性用品。那天没有宏大的口号，只有一袋袋被运走的垃圾和许多人心里悄悄发生的改变。')
        WHEN 2 THEN CONCAT('第', n, '篇：林女士经营一家小咖啡店。开业初期，她把大部分精力放在装修和菜单上，却忽视了顾客等待的时间。周末客人多的时候，柜台前常常排起长队，有人甚至因为等得太久而离开。后来，她观察了整个流程，发现点单、制作和取餐之间缺少清晰的提示。于是她重新设计了排队路线，增加了号码牌，还把常见饮品的准备材料提前摆好。改变并不复杂，却让店里的节奏顺畅了许多。林女士由此明白，好的服务并不总是来自昂贵的设备，而是来自对细节的持续观察。')
        WHEN 3 THEN CONCAT('第', n, '篇：学校的科学社团准备制作一个小型气象站。学生们需要测量温度、记录风向，并观察每天的云层变化。刚开始，他们只对仪器感兴趣，经常忘记在固定时间填写表格。指导老师没有直接批评，而是让大家比较缺失数据前后的图表。学生们发现，哪怕只少了几天记录，趋势也会变得模糊。于是他们安排了轮值表，并在教室门口贴上提醒。一个月后，他们用完整的数据做出了第一份报告。虽然报告还很简单，但每个成员都理解了坚持记录对科学观察的重要性。')
        WHEN 4 THEN CONCAT('第', n, '篇：老街上有一家修鞋铺，店主赵师傅已经工作了三十多年。许多年轻人觉得修鞋是一门过时的手艺，但附近居民仍愿意把旧鞋送到他那里。赵师傅会仔细检查鞋底、鞋面和缝线，再告诉顾客是否值得修。有时他会建议顾客不要花钱，因为鞋子已经磨损严重。正是这种诚实，让他的店一直有人光顾。后来，社区邀请他给学生做一次职业介绍。赵师傅带去几件工具，讲述每道工序背后的耐心。学生们发现，普通职业里也藏着专业和尊严。')
        WHEN 5 THEN CONCAT('第', n, '篇：一次长途旅行中，列车因为暴雨临时停在小站。乘客们一开始有些焦急，不断查看手机上的通知。过了一会儿，车厢里的气氛慢慢缓和下来。有人把零食分给旁边的孩子，有人帮助老人把行李放稳，还有几名学生小声练习第二天的演讲。列车员不断向大家说明最新情况，并提醒乘客注意安全。三个小时后，列车重新出发。很多人并不记得延误的具体时间，却记住了陌生人之间短暂而真诚的照顾。')
        WHEN 6 THEN CONCAT('第', n, '篇：为了准备校园艺术节，音乐老师组织了一支临时合唱队。队员来自不同年级，声音条件也不一样。第一次排练时，大家唱得并不整齐，有人抢拍，有人忘词，还有人声音太小。老师没有急着追求响亮的效果，而是先让学生学会倾听旁边的人。她要求每个人在唱自己的声部时，也注意整体的平衡。经过几周练习，合唱队的声音逐渐融合。演出结束后，学生们最开心的不是掌声，而是发现合作可以让普通的声音变得丰富。')
        WHEN 7 THEN CONCAT('第', n, '篇：新开的社区菜园吸引了许多居民。每个家庭可以认领一小块土地，种植自己喜欢的蔬菜。刚开始，有些人只顾自己的地块，很少交流。后来，几位老人主动分享浇水和除虫的经验，还把多余的种子放在公共箱里。孩子们周末来观察幼苗，学习区分叶子的形状。到了收获季节，大家把蔬菜摆在长桌上，一起做了一顿简单的午餐。菜园不仅提供了新鲜食物，也让原本陌生的邻居有了自然交谈的理由。')
        WHEN 8 THEN CONCAT('第', n, '篇：出版社编辑周女士每天要阅读大量稿件。她知道，并不是每个故事都成熟，也不是每个作者都能立刻接受修改意见。面对新作者时，她通常先指出作品中最有力量的部分，再讨论结构和语言的问题。有一次，一位作者因为删掉整章内容而感到沮丧。周女士耐心解释，删除并不意味着否定努力，而是为了让主题更清楚。几个月后，那篇文章终于发表。作者在感谢信里写道，真正的修改不是把文字变少，而是让表达更准确。')
        ELSE CONCAT('第', n, '篇：山村小学收到一批新的体育器材。校长没有立刻分发，而是召集老师和学生代表一起制定使用规则。他们讨论了借用时间、保管责任和安全提醒，还决定每周安排一次共同检查。起初，有学生觉得规则太细，但几周后大家发现，器材没有丢失，也很少损坏。更多孩子有机会参加运动，因为每个人都知道该怎样公平使用。这个经验让学校明白，资源本身很重要，管理资源的方式同样重要。清楚的规则可以减少争抢，也能让善意真正持续下去。')
      END
    END AS chinese_text,
    CASE level_no
      WHEN 1 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN 'The morning sky is blue.'
        WHEN 1 THEN 'She reads books every day.'
        WHEN 2 THEN 'Children play in the garden.'
        WHEN 3 THEN 'Please open the door.'
        WHEN 4 THEN 'My friend likes music.'
        WHEN 5 THEN 'The air is fresh after rain.'
        WHEN 6 THEN 'The teacher enters the classroom smiling.'
        WHEN 7 THEN 'Dinner is ready now.'
        WHEN 8 THEN 'This book is interesting.'
        ELSE 'We will visit the park tomorrow.'
      END
      WHEN 2 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN 'The morning bus arrives on time, and the students wait quietly in line.'
        WHEN 1 THEN 'She found a useful book in the library and took careful notes.'
        WHEN 2 THEN 'The children practice running after school to prepare for the sports meeting.'
        WHEN 3 THEN 'If the weather is clear tomorrow, we will walk by the lake together.'
        WHEN 4 THEN 'My friend is learning to cook because he wants to care for his family.'
        WHEN 5 THEN 'The small shop is not large, but the bread is fresh and the service is warm.'
        WHEN 6 THEN 'After the teacher explained the question, many students finally understood the method.'
        WHEN 7 THEN 'After dinner, father turned off the television and helped my sister practice English sounds.'
        WHEN 8 THEN 'This movie tells the story of an ordinary person who keeps following a dream.'
        ELSE 'We plan to clean the room this weekend and then sort old books and clothes.'
      END
      WHEN 3 THEN CASE MOD(n - 1, 10)
        WHEN 0 THEN 'In the morning, the path in the community was still quiet. Li Ming left home with his schoolbag and saw a cleaner sweeping fallen leaves. He slowed down and greeted the worker politely. After he arrived at school, he wrote the small moment in his diary. It reminded him to respect every person who works carefully.'
        WHEN 1 THEN 'On Saturday afternoon, Anna went to the market with her mother. They bought fruit first and then chose fresh vegetables. When they returned home, Anna helped wash tomatoes and set the table. The dinner was simple, but the family felt warm because everyone had taken part in preparing it.'
        WHEN 2 THEN 'During the school reading meeting, Mr Wang asked every student to introduce a favorite book. Xiaoya felt nervous, but she had prepared an outline in advance. When it was her turn, she slowly explained the story and shared her feelings. At the end, her classmates gave her warm applause.'
        WHEN 3 THEN 'The rain was heavy, so the game on the playground had to be delayed. Several students were not disappointed. They stayed in the classroom and arranged the equipment. They checked the rackets, dried the basketballs, and posted the name list again. When the weather became clear, the activity started smoothly.'
        WHEN 4 THEN 'Uncle Chen rides to work every day and passes a river on the way. He enjoys watching the riverbank change through the seasons. There is new grass in spring, lotus flowers in summer, fallen leaves in autumn, and thin ice in winter. These ordinary scenes make his commute peaceful and pleasant.'
        WHEN 5 THEN 'The class prepared an English short play, and everyone had a role. Some students revised the lines, some prepared costumes, and others took care of the music. Mistakes often happened during rehearsal, but the students reminded one another kindly. On performance day, they did not chase perfection. They simply tried to tell the story clearly.'
        WHEN 6 THEN 'Grandmother taught Xiaolin how to make dumplings. At first, he always put in too much filling, so the dumplings would not close. Grandmother did not criticize him. She showed him how to control the amount. After several tries, Xiaolin finally made neat dumplings and understood why patience matters.'
        WHEN 7 THEN 'The library opened a new study area. The librarian reminded everyone to stay quiet and set phones to silent mode. Many students liked the place because the desks were wide and the lights were soft. Before exams, the seats filled quickly. The calm room helped students focus for a longer time.'
        WHEN 8 THEN 'In a class meeting, the teacher asked students to discuss how to save water. The students suggested many ideas, such as turning off taps quickly, washing vegetables in a basin, and using rainwater for flowers. After the discussion, the class decided to record their water habits from that day.'
        ELSE 'The small town railway station opened again. When the first train arrived, many residents stood on the platform and took photos. Older people remembered past journeys, while children looked curiously at the carriages. This ordinary morning made the town lively again and gave people something new to talk about.'
      END
      ELSE CASE MOD(n - 1, 10)
        WHEN 0 THEN 'At the edge of the city, there was a small community school. The school did not have a grand hall, but it had a reading room where the lights were always on. Every day after class, students put their bags in the corner and sat around a long table to read. Ms Chen, the librarian, recommended books for each child. Some children liked science stories, some liked historical people, and others only wanted a light comic book. Ms Chen never pushed them to choose harder books, because she believed that a steady reading habit was more important than finishing one thick book. After one term, many students began to write reading notes and copy favorite sentences on cards. The reading room slowly became the quietest and most lively place in the school.'
        WHEN 1 THEN 'On a spring Saturday, volunteers came to the riverbank to clean up rubbish. At first, everyone thought the task would be simple. They expected to pick up plastic bottles and waste paper. After they moved closer to the bank, however, they found old bags, drink cans, and food packages hidden under grass and mud. The team leader divided people into three groups. One group sorted the rubbish, one group recorded the amount, and the third group contacted a truck. Two hours later, the riverbank looked much cleaner. More importantly, nearby residents saw the work and began to discuss how to reduce disposable products. There were no grand slogans that day, only bags of rubbish being carried away and quiet changes in many minds.'
        WHEN 2 THEN 'Ms Lin runs a small coffee shop. In the beginning, she spent most of her energy on decoration and the menu, but she ignored how long customers had to wait. On busy weekends, a long line often formed in front of the counter, and some people left before ordering. Later, she observed the whole process and found that ordering, making drinks, and picking them up lacked clear signals. She redesigned the line, added number cards, and prepared materials for common drinks in advance. The change was not complicated, but the rhythm of the shop became much smoother. Ms Lin learned that good service does not always come from expensive equipment. It often comes from careful observation of details.'
        WHEN 3 THEN 'The school science club planned to build a small weather station. Students needed to measure temperature, record wind direction, and observe cloud changes every day. At first, they were more interested in the instruments than in the routine, so they often forgot to fill in the form at the same time. The teacher did not criticize them directly. Instead, she asked them to compare charts with and without missing data. The students found that even a few lost records could make a trend unclear. They created a duty schedule and placed a reminder near the classroom door. One month later, they produced their first report with complete data. The report was simple, but every member understood why steady records matter in scientific observation.'
        WHEN 4 THEN 'On an old street, there is a shoe repair shop. Mr Zhao, the owner, has worked there for more than thirty years. Many young people think shoe repair is an old-fashioned skill, but nearby residents still bring worn shoes to him. Mr Zhao checks the soles, the leather, and the stitches carefully before telling customers whether a repair is worth the cost. Sometimes he advises them not to spend money because the shoes are too badly damaged. This honesty keeps people coming back. Later, the community invited him to speak to students about his job. He brought several tools and explained the patience behind each step. The students discovered that ordinary work can also contain skill and dignity.'
        WHEN 5 THEN 'During a long journey, a train stopped at a small station because of heavy rain. At first, passengers felt worried and kept checking notices on their phones. After a while, the mood in the carriage became calmer. Someone shared snacks with a child nearby, someone helped an older passenger steady a suitcase, and several students quietly practiced a speech for the next day. The conductor continued to explain the latest situation and reminded everyone to stay safe. Three hours later, the train started again. Many passengers did not remember the exact length of the delay, but they remembered the short and sincere care among strangers.'
        WHEN 6 THEN 'To prepare for the school art festival, the music teacher organized a temporary choir. The members came from different grades, and their voices were quite different. During the first rehearsal, the singing was not neat. Some students came in too early, some forgot the words, and others sang too softly. The teacher did not rush to make the sound loud. She first taught students to listen to the people beside them. She asked everyone to sing their own part while noticing the balance of the whole group. After several weeks, the voices gradually blended. After the performance, the students were happiest not because of applause, but because they found that cooperation could make ordinary voices rich.'
        WHEN 7 THEN 'The new community vegetable garden attracted many residents. Each family could take care of a small piece of land and grow vegetables they liked. At first, some people only worked on their own plots and rarely talked with others. Later, several older residents shared advice about watering and removing insects. They also placed extra seeds in a public box. Children came on weekends to watch young plants and learn the shapes of leaves. At harvest time, everyone put vegetables on a long table and cooked a simple lunch together. The garden provided fresh food, but it also gave neighbors who had once been strangers a natural reason to talk.'
        WHEN 8 THEN 'Ms Zhou, an editor at a publishing house, reads many manuscripts every day. She knows that not every story is mature and not every writer can accept advice immediately. When she works with new writers, she usually points out the strongest part of a piece before discussing problems in structure and language. Once, a writer felt upset because a whole chapter had to be removed. Ms Zhou explained patiently that deletion did not mean the effort was wasted. It was meant to make the theme clearer. Several months later, the article was published. In a thank you note, the writer said that real revision is not simply making text shorter. It is making expression more accurate.'
        ELSE 'A village school received a new set of sports equipment. The principal did not hand it out at once. Instead, he invited teachers and student representatives to make rules together. They discussed borrowing times, storage duties, and safety reminders. They also decided to check the equipment together once a week. At first, some students thought the rules were too detailed. After a few weeks, however, everyone noticed that the equipment was not lost and was rarely damaged. More children had chances to join sports because everyone knew how to use the resources fairly. The experience taught the school that resources are important, but the way resources are managed is just as important. Clear rules can reduce arguments and help goodwill last.'
      END
    END AS english_text
  FROM seq
  CROSS JOIN levels
),
counted_rows AS (
  SELECT
    id,
    level,
    title,
    chinese_text,
    english_text,
    TRIM(REGEXP_REPLACE(english_text, '[^A-Za-z]+', ' ')) AS word_text
  FROM source_rows
)
SELECT
  id,
  level,
  title,
  chinese_text,
  english_text,
  CASE
    WHEN word_text = '' THEN 0
    ELSE 1 + CHAR_LENGTH(word_text) - CHAR_LENGTH(REPLACE(word_text, ' ', ''))
  END AS word_count
FROM counted_rows
ON DUPLICATE KEY UPDATE
  `level` = VALUES(`level`),
  `title` = VALUES(`title`),
  `chinese_text` = VALUES(`chinese_text`),
  `english_text` = VALUES(`english_text`),
  `word_count` = VALUES(`word_count`),
  `updated_at` = CURRENT_TIMESTAMP;
