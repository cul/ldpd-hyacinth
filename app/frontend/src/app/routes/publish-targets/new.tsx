import { QueryClient } from '@tanstack/react-query';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { PublishTargetForm } from '@/features/publish-targets/components/publish-target-form';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);
  return null;
};

const PublishTargetsNewRoute = () => {
  return (
    <PublishTargetForm />
  );
};

export default PublishTargetsNewRoute;