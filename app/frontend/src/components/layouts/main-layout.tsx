import TopNavbar from '../topnavbar';

// type SideNavigationItem = {
//   name: string;
//   to: string;
//   icon: (props: React.SVGProps<SVGSVGElement>) => JSX.Element;
// };

// const Logo = () => {
//   return (
//     <Link className="flex items-center text-white" to={paths.home.getHref()}>
//       <img className="h-8 w-auto" src={logo} alt="Workflow" />
//       <span className="text-sm font-semibold text-white">
//         Bulletproof React
//       </span>
//     </Link>
//   );
// };


export function MainLayout({ children }: { children: React.ReactNode }) {
  // const navigate = useNavigate();
  // const logout = useLogout({
  //   onSuccess: () => navigate(paths.auth.login.getHref(location.pathname)),
  // });
  // const { checkAccess } = useAuthorization();
  // const navigation = [
  //   { name: 'Dashboard', to: paths.app.dashboard.getHref(), icon: Home },
  //   { name: 'Discussions', to: paths.app.discussions.getHref(), icon: Folder },
  //   checkAccess({ allowedRoles: [ROLES.ADMIN] }) && {
  //     name: 'Users',
  //     to: paths.app.users.getHref(),
  //     icon: Users,
  //   },
  // ].filter(Boolean) as SideNavigationItem[];

  return (
    <div className="flex min-h-screen w-full flex-col bg-muted/40">
      <TopNavbar />
      <main className="grid flex-1 items-start gap-4 p-4 sm:px-6 sm:py-0 md:gap-8">
        {children}
      </main>
    </div>
  );
}