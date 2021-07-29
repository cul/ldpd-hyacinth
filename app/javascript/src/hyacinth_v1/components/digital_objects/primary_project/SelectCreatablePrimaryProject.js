import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { getProjectsQuery } from '../../../graphql/projects';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import Label from '../../shared/forms/Label';
import InputGroup from '../../shared/forms/InputGroup';
import GraphQLErrors from '../../shared/GraphQLErrors';
import ability from '../../../utils/ability';

function SelectCreatablePrimaryProject({ primaryProject, changeHandler }) {
  const { loading, error, data } = useQuery(getProjectsQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);
  const allowedCreateProjects = data.projects.filter(({ stringKey }) => (
    ability.can('create_objects', { subjectType: 'Project', stringKey })
  ));
  const selectOptions = allowedCreateProjects.map(
    p => ({ value: p.stringKey, label: p.displayLabel }),
  );

  const projectForStringKey = (key) => {
    const retVal = allowedCreateProjects.find(({ stringKey }) => { return stringKey === key; });
    return retVal;
  };

  return (
    <InputGroup>
      <Label sm={3}>Primary Project</Label>
      <SelectInput
        sm={9}
        name="primary_project"
        value={primaryProject ? primaryProject.stringKey : ''}
        onChange={v => changeHandler(projectForStringKey(v))}
        options={selectOptions}
      />
    </InputGroup>
  );
}

SelectCreatablePrimaryProject.propTypes = {
  primaryProject: PropTypes.object,
  changeHandler: PropTypes.func.isRequired,
};

export default SelectCreatablePrimaryProject;
