// Actions will be populated with server-side data when app loads:
export const ProjectAction = {};
export const ProjectActions = [];
export const PrimaryProjectActions = [];
export const AggregatorProjectActions = [];

export const setupPermissionActions = (permissionActions) => {
  const { projectActions, primaryProjectActions, aggregatorProjectActions } = permissionActions;

  // Set up frozen ProjectAction object so we can reference actions
  // using ProjectAction.read_objects, ProjectAction.manage etc.
  projectActions.forEach((action) => {
    ProjectAction[action] = action;
  });
  Object.freeze(ProjectAction);

  // Set up frozen arrays so we can iterate through project actions for permission editing forms.
  ProjectActions.push(...projectActions);
  Object.freeze(ProjectActions);

  PrimaryProjectActions.push(...primaryProjectActions);
  Object.freeze(PrimaryProjectActions);

  AggregatorProjectActions.push(...aggregatorProjectActions);
  Object.freeze(AggregatorProjectActions);
};
