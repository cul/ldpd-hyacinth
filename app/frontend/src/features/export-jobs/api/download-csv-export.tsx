import { BASE_URL } from '@/lib/api-client';

export const getCsvExportDownloadUrl = (exportJobId: number) =>
  `${BASE_URL}/csv_exports/${exportJobId}/download`;
