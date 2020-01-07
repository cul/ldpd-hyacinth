import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { getProjectsQuery } from '../../../graphql/projects';
import SelectInput from '../../ui/forms/inputs/SelectInput';
import Label from '../../ui/forms/Label';
import InputGroup from '../../ui/forms/InputGroup';
import GraphQLErrors from '../../ui/GraphQLErrors';
import ability from '../../../util/ability';

function SelectPrimaryProject({ primaryProject, changeHandler }) {
  const { loading, error, data } = useQuery(getProjectsQuery, { isPrimary: true });

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

SelectPrimaryProject.propTypes = {
  primaryProject: PropTypes.object,
  changeHandler: PropTypes.func.isRequired,
};

export default SelectPrimaryProject;
