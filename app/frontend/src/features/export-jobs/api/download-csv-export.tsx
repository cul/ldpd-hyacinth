import { BASE_URL } from '@/lib/api-client';

export const getCsvExportDownloadUrl = (exportJobId: number) =>
  `${BASE_URL}/export_jobs/${exportJobId}/download`;
