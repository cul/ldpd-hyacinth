import { QueryClient } from '@tanstack/react-query';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { getProjectsQueryOptions } from '@/features/projects/api/get-projects';
import { PublishTargetForm } from '@/features/publish-targets/components/publish-target-form';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  // No need to wait on this data as it's only needed for the projects dropdown
  queryClient.prefetchQuery(getProjectsQueryOptions());
};

const PublishTargetsNewRoute = () => {
  return (
    <PublishTargetForm />
  );
};

export default PublishTargetsNewRoute;