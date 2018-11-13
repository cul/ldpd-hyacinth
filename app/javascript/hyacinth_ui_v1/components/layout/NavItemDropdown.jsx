import React from 'react'

export default class NavItemDropdown extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      show: this.props.show,
      dropdownDirection: this.props.dropdownDirection
    }

    // Create a reference to this dropdown's top level element so we can
    // later detect clicks outside of this element.
    // We'll associate this ref with the element in the render function.
    this.containerLi = React.createRef();

    // bind functions that should always run in the context of this instance
    this.toggle = this.toggle.bind(this);
    this.hide = this.hide.bind(this);
    this.handleClickOutside = this.handleClickOutside.bind(this);
  }

  toggle(e) {
    e.preventDefault(); // prevent hashchange when visibility is toggled
    this.setState((state, props) => {
      return {show: !state.show};
    });
  }

  hide(e) {
    this.setState((state, props) => {
      return {show: false};
    });
  }

  handleClickOutside(event) {
    // if we clicked outside the container <li> element...
    if (this.containerLi.current && !this.containerLi.current.contains(event.target)) {
      // change show state to hide dropdown content
      this.setState((state, props) => {
        return {show: false};
      });
    }
  }

  render() {
    return(
      <li className="nav-item dropdown" ref={this.containerLi}>
        <a className="nav-link dropdown-toggle" href="#" onClick={this.toggle}>
          {this.props.label}
        </a>
        <div className={'dropdown-menu ' + (this.state.dropdownDirection == 'right' ? 'dropdown-menu-right' : '') + ' ' + (this.state.show ? 'show' : '')} onClick={this.hide}>
          {this.props.children}
        </div>
      </li>
    )
  }

  componentDidMount() {
    document.addEventListener('click', this.handleClickOutside);
  }

  componentWillUnmount() {
    document.removeEventListener('click', this.handleClickOutside);
  }
}

// Specifies the default values for props:
NavItemDropdown.defaultProps = {
  show: false,
  dropdownDirection: 'left'
};
