import React from 'react';
import PropTypes from 'prop-types';
import ProjectShow from './ProjectShow';

const ProjectsShow = (props) => {
  const { digitalObject: { primaryProject, otherProjects } } = props;
  return (
    <>
      <h4>Primary Project</h4>
      <p className="inline-badge-list"><ProjectShow stringKey={primaryProject.stringKey} displayLabel={primaryProject.displayLabel} /></p>
      <h4>Other Projects</h4>
      <p className="inline-badge-list">
        {
        otherProjects?.map((p) => (
          <ProjectShow stringKey={p.stringKey} displayLabel={p.displayLabel} />
        )) || 'None'
        }
      </p>
    </>
  );
};

ProjectsShow.propTypes = {
  digitalObject: PropTypes.shape({
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

export default ProjectsShow;
