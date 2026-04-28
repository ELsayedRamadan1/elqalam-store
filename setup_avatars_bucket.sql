-- إنشاء bucket للصور الشخصية
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- إنشاء سياسة للسماح للمستخدمين برفع صورهم الشخصية
CREATE POLICY "Users can upload their own avatar" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- إنشاء سياسة للسماح للمستخدمين بقراءة صورهم الشخصية
CREATE POLICY "Users can view avatars" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- إنشاء سياسة للسماح للمستخدمين بتحديث صورهم الشخصية
CREATE POLICY "Users can update their own avatar" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- إنشاء سياسة للسماح للمستخدمين بحذف صورهم الشخصية
CREATE POLICY "Users can delete their own avatar" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
