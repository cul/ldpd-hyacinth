import { db } from './db';

// Our users rely on OmniAuth for authentication so a password is not needed.
export function authenticate({ uid }: { uid: string }) {
  const user = db.user.findFirst((user) => user.uid === uid);

  if (!user) {
    throw new Error('User not found');
  }

  return { user };
}