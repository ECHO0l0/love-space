-- ================================================
-- 我们的秘密花园 — Supabase 数据库初始化脚本
-- 在 Supabase > SQL Editor 中粘贴并运行
-- ================================================

-- 1. 宠物表
CREATE TABLE IF NOT EXISTS pet (
  id INTEGER PRIMARY KEY DEFAULT 1,
  name TEXT DEFAULT '小可爱',
  hunger INTEGER DEFAULT 100,
  happiness INTEGER DEFAULT 100,
  last_fed TIMESTAMPTZ DEFAULT NOW(),
  last_played TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 插入默认宠物（只插入一次）
INSERT INTO pet (id, name, hunger, happiness)
VALUES (1, '小可爱', 100, 100)
ON CONFLICT (id) DO NOTHING;

-- 2. 花园表
CREATE TABLE IF NOT EXISTS garden (
  id SERIAL PRIMARY KEY,
  plot_index INTEGER NOT NULL UNIQUE,
  plant_type TEXT,
  planted_at TIMESTAMPTZ,
  watered_at TIMESTAMPTZ,
  stage INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 插入 6 块空地
INSERT INTO garden (plot_index, stage) VALUES
  (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0)
ON CONFLICT (plot_index) DO NOTHING;

-- 3. 活动日志表
CREATE TABLE IF NOT EXISTS activities (
  id SERIAL PRIMARY KEY,
  icon TEXT DEFAULT '📝',
  user_name TEXT DEFAULT '另一半',
  action TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 开启 Realtime（实时同步）
ALTER PUBLICATION supabase_realtime ADD TABLE pet;
ALTER PUBLICATION supabase_realtime ADD TABLE garden;
ALTER PUBLICATION supabase_realtime ADD TABLE activities;

-- 5. 关闭 RLS（因为是私人空间，靠暗号保护即可）
-- 如果你想要更安全，可以开启 RLS 并设置策略
ALTER TABLE pet ENABLE ROW LEVEL SECURITY;
ALTER TABLE garden ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- 允许所有操作（因为是私人项目）
CREATE POLICY "允许所有" ON pet FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "允许所有" ON garden FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "允许所有" ON activities FOR ALL USING (true) WITH CHECK (true);
