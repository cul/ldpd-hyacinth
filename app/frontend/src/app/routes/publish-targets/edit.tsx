import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { getPublishTargetQueryOptions } from '@/features/publish-targets/api/get-publish-target';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const publishTargetStringKey = params.publishTargetStringKey as string;

  const publishTargetQuery = getPublishTargetQueryOptions(publishTargetStringKey);

  return await queryClient.ensureQueryData(publishTargetQuery);
};

const PublishTargetsEditRoute = () => {
  const params = useParams();
  const publishTargetStringKey = params.publishTargetStringKey as string;

  return (
    <div>
      <h1>Edit Publish Target</h1>
      <p>Publish Target String Key: {publishTargetStringKey}</p> 
    </div>
  )
};

export default PublishTargetsEditRoute;