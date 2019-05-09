import React from 'react';

class ProjectSubHeading extends React.Component {
  render() {
    return (
      <h4 className="mb-3 pt-2 pb-1 text-center">{this.props.children}</h4>
    );
  }
}

export default ProjectSubHeading;
