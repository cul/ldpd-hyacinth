import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { getPublishTargetQueryOptions, usePublishTargetSuspense } from '@/features/publish-targets/api/get-publish-target';
import { PublishTargetForm } from '@/features/publish-targets/components/publish-target-form';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const publishTargetStringKey = params.publishTargetStringKey as string;

  const publishTargetQuery = getPublishTargetQueryOptions(publishTargetStringKey);

  return await queryClient.ensureQueryData(publishTargetQuery);
};

const PublishTargetsEditRoute = () => {
  const params = useParams();
  const publishTargetStringKey = params.publishTargetStringKey as string;

  const publishTargetQuery = usePublishTargetSuspense({ publishTargetStringKey });
  const publishTarget = publishTargetQuery?.data?.publishTarget;

  return (
    <div>
      <PublishTargetForm publishTarget={publishTarget} />
    </div>
  )
};

export default PublishTargetsEditRoute;