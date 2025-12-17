// Test API call to get users, this would normally go through an api client with auth headers etc.
export const getUsers = async (): Promise<any[]> => {
  const url = 'http://localhost:3000/api/v2/users';

  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`Response status: ${response.status}`);
    }

    const result = await response.json();
    console.log(result);
    return result.users;
  } catch (error: any) {
    console.error(error.message);
    return [];
  }
};