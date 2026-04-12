-- Add new template types while keeping old ones for backward compatibility
ALTER TABLE demos DROP CONSTRAINT IF EXISTS demos_template_check;
ALTER TABLE demos ADD CONSTRAINT demos_template_check CHECK (
  template IN (
    'restaurant', 'professional', 'health_beauty',
    'warm_organic', 'soft_glass', 'editorial_luxury',
    'bold_modern', 'fresh_startup', 'dark_premium'
  )
);
