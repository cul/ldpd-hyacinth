import React, { useState } from 'react';
import { useMutation } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import { digitalObjectAbility } from '../../../utils/ability';
import FormButtons from '../../shared/forms/FormButtons';
import GraphQLErrors from '../../shared/GraphQLErrors';
import SelectCreatablePrimaryProject from '../primary_project/SelectCreatablePrimaryProject';
import { updateProjectsMutation } from '../../../graphql/digitalObjects';
import OtherProjectsSelect from './OtherProjectsSelect';
import ProjectShow from './ProjectShow';
import UserErrorsList from '../../shared/UserErrorsList';

const onlyStringKey = (obj) => ({ stringKey: obj.stringKey });

const ProjectsEdit = ({ digitalObject }) => {
  const [updateProjects, { data: updateData, error: updateErrors }] = useMutation(
    updateProjectsMutation,
  );
  const userErrors = updateData?.updateProjects?.userErrors;
  const [primaryProject, setPrimaryProject] = useState({ ...digitalObject.primaryProject });
  const [otherProjects, setOtherProjects] = useState([...digitalObject.otherProjects]);
  const editPrimary = digitalObjectAbility.can('delete_objects', { primaryProject, otherProjects: [] });

  const onSave = () => {
    const variables = {
      input: {
        id: digitalObject.id,
        primaryProject: onlyStringKey(primaryProject),
        otherProjects: otherProjects.map(onlyStringKey),
      },
    };
    return updateProjects({ variables }).then((res) => {
      if (res?.data?.updateProjects?.userErrors?.[0]) {
        throw new Error('Error in project assignment');
      } else {
        return res;
      }
    });
  };

  const onSaveSuccess = (res) => {
    const objectUpdate = res?.data?.updateProjects?.digitalObject;
    if (objectUpdate) {
      setPrimaryProject(objectUpdate.primaryProject);
      setOtherProjects(objectUpdate.otherProjects);
    }
  };
  return (
    <form>
      <h4>Primary Project</h4>
      {updateErrors && <GraphQLErrors errors={updateErrors} />}
      {userErrors && <UserErrorsList userErrors={userErrors} />}
      <p className="inline-badge-list">
        {editPrimary ? <SelectCreatablePrimaryProject primaryProject={primaryProject} changeHandler={setPrimaryProject} ariaLabelOnly />
          : <ProjectShow stringKey={primaryProject.stringKey} displayLabel={primaryProject.displayLabel} />}
      </p>
      <h4>Other Projects</h4>
      <OtherProjectsSelect primaryProject={primaryProject} otherProjects={otherProjects} changeHandler={setOtherProjects} />
      <FormButtons
        formType="edit"
        onSave={onSave}
        onSaveSuccess={onSaveSuccess}
      />
    </form>
  );
};

ProjectsEdit.propTypes = {
  digitalObject: PropTypes.shape({
    id: PropTypes.string.isRequired,
    primaryProject: PropTypes.shape({
      stringKey: PropTypes.string.isRequired,
      displayLabel: PropTypes.string.isRequired,
    }).isRequired,
    otherProjects: PropTypes.arrayOf(
      PropTypes.shape({
        stringKey: PropTypes.string.isRequired,
      }),
    ).isRequired,
  }).isRequired,
};

export default ProjectsEdit;
