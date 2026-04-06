import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { getProjectsQueryOptions } from '@/features/projects/api/get-projects';
import { getPublishTargetQueryOptions, usePublishTargetSuspenseQuery } from '@/features/publish-targets/api/get-publish-target';
import { PublishTargetForm } from '@/features/publish-targets/components/publish-target-form';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  // No need to wait on this data as it's only needed for the projects dropdown
  queryClient.prefetchQuery(getProjectsQueryOptions());

  const publishTargetStringKey = params.publishTargetStringKey as string;
  const publishTargetQuery = getPublishTargetQueryOptions(publishTargetStringKey);
  return await queryClient.ensureQueryData(publishTargetQuery);
};

const PublishTargetsEditRoute = () => {
  const params = useParams();
  const publishTargetStringKey = params.publishTargetStringKey as string;

  const publishTargetQuery = usePublishTargetSuspenseQuery({ publishTargetStringKey });
  const publishTarget = publishTargetQuery?.data?.publishTarget;

  return (
    <PublishTargetForm publishTarget={publishTarget} />
  )
};

export default PublishTargetsEditRoute;