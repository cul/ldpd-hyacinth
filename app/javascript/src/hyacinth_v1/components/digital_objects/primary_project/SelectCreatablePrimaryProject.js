import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { getProjectsQuery } from '../../../graphql/projects';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import Label from '../../shared/forms/Label';
import InputGroup from '../../shared/forms/InputGroup';
import GraphQLErrors from '../../shared/GraphQLErrors';
import ability from '../../../utils/ability';

function SelectCreatablePrimaryProject({ primaryProject, changeHandler, ariaLabelOnly }) {
  const { loading, error, data } = useQuery(getProjectsQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);
  const allowedCreateProjects = data.projects.filter(({ stringKey }) => (
    ability.can('create_objects', { subjectType: 'Project', stringKey })
  ));
  const selectOptions = allowedCreateProjects.map(
    (p) => ({ value: p.stringKey, label: p.displayLabel }),
  );

  const projectForStringKey = (key) => {
    const retVal = allowedCreateProjects.find(({ stringKey }) => stringKey === key);
    return retVal;
  };

  return (
    <InputGroup>
      {!ariaLabelOnly && <Label sm={3} htmlFor="primary_project">Primary Project</Label> }
      <SelectInput
        sm={9}
        name="primary_project"
        aria={{ label: 'Primary Project' }}
        value={primaryProject ? primaryProject.stringKey : ''}
        onChange={(v) => changeHandler(projectForStringKey(v))}
        options={selectOptions}
      />
    </InputGroup>
  );
}

SelectCreatablePrimaryProject.defaultProps = {
  primaryProject: null,
  ariaLabelOnly: false,
};

SelectCreatablePrimaryProject.propTypes = {
  ariaLabelOnly: PropTypes.bool,
  primaryProject: PropTypes.shape({
    stringKey: PropTypes.string.isRequired,
  }),
  changeHandler: PropTypes.func.isRequired,
};

export default SelectCreatablePrimaryProject;
