import { Card } from 'react-bootstrap';
import { QueueActivity } from '@/types/api';
import { useQueueActivitySuspenseQuery } from '../api/get-queue-activity';

type PriorityConfig = {
  key: keyof QueueActivity;
  label: string;
  color: string;
};

const PRIORITIES: PriorityConfig[] = [
  { key: 'high', label: 'High', color: '#b03a3a' },
  { key: 'medium', label: 'Medium', color: '#c87d1a' },
  { key: 'low', label: 'Low', color: '#2e7d5a' },
];

export const QueueActivityDisplay = () => {
  const { data } = useQueueActivitySuspenseQuery();
  const queueActivity = data?.queueActivity as QueueActivity;

  return (
    <Card className="mb-3 border-0 bg-light">
      <Card.Body className="py-2 px-3">
        <div className="d-flex align-items-center gap-4 flex-wrap">
          <small className="fw-semibold text-muted text-nowrap">Queue Activity (all users):</small>
          <div className="d-flex gap-3">
            {PRIORITIES.map(({ key, label, color }) => (
              <div key={key} className="d-flex align-items-center gap-2">
                <span className="badge rounded-pill text-white" style={{ backgroundColor: color }}>
                  {queueActivity[key]}
                </span>
                <small className="text-muted">{label} Priority</small>
              </div>
            ))}
          </div>
        </div>
      </Card.Body>
    </Card>
  );
};
