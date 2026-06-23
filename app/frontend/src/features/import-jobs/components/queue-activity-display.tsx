import { QueueActivity } from '@/types/api';
import { useQueueActivitySuspenseQuery } from '../api/get-queue-activity';

export const QueueActivityDisplay = () => {
  const { data } = useQueueActivitySuspenseQuery();
  const queueActivity = data?.queueActivity as QueueActivity;

  // TODO: Make it look nice
  return (
    <div className="flex gap-2 mb-4">
      <div className="flex items-center gap-2">
        <span className="font-semibold">Low Priority:</span>
        <span>{queueActivity.low}</span>
      </div>
      <div className="flex items-center gap-2">
        <span className="font-semibold">Medium Priority:</span>
        <span>{queueActivity.medium}</span>
      </div>
      <div className="flex items-center gap-2">
        <span className="font-semibold">High Priority:</span>
        <span>{queueActivity.high}</span>
      </div>
    </div>
  );
};
