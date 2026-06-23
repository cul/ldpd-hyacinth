export const ImportJobDetail = ({ importJob }: { importJob: any }) => {
  return (
    <div>
      <h1>{importJob.id}</h1>
      <p>Status: {importJob.status}</p>
      <p>Priority: {importJob.priority}</p>
    </div>
  );
};
