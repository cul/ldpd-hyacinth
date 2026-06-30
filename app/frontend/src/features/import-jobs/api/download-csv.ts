// These methods don't use the shared API client because they are used to download files which doesn't work with JSON responses.
// Instead, these methods return the download URLs for the CSV files, which can be used in an anchor tag or a fetch request to download the files directly.

import { BASE_URL } from '@/lib/api-client';

export const getOriginalCsvDownloadUrl = (importJobId: number) =>
  `${BASE_URL}/import_jobs/${importJobId}/download_original_csv`;

export const getCsvWithoutSuccessfulRowsDownloadUrl = (importJobId: number) =>
  `${BASE_URL}/import_jobs/${importJobId}/download_csv_without_successful_rows`;
