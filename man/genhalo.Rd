\name{genhalo}
\alias{genhalo}
\title{
Generate an equilibrium Hernquist halo
}
\description{
This function generates a Herquist halo in thermal equilibrium. You can add net spatial and velocity offsets, making it easy to generate a family of halos for Gadget ICs.
}
\usage{
genhalo(x = 0, y = 0, z = 0, vx = 0, vy = 0, vz = 0, Npart = 1000, Mpart = 1,
 conc = 10, iseed = 87618820, Munit=1e10, Lunit=1e3, Vunit=1, IDoffset=0)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
Net x positional offset in  units of Lunit (default Kpc)
}
  \item{y}{
Net y positional offset in  units of Lunit (default Kpc)
}
  \item{z}{
Net z positional offset in  units of Lunit (default Kpc)
}
  \item{vx}{
Net x velocity offset in units of Vunit (default km/s)
}
  \item{vy}{
Net y velocity offset in units of Vunit (default km/s)
}
  \item{vz}{
Net z velocity offset in units of Vunit (default km/s)
}
  \item{Npart}{
The number of particles within the Virial radius desired (number of particles generated will be a few 10% larger since the function generates particles beyond the Virial radius
}
  \item{Mpart}{
The mass of each particle in units of Munit (default 1e10*Msun)
}
  \item{conc}{
The concentration of the profile desired
}
  \item{iseed}{
The initial random seed
}
  \item{Munit}{
Mass unit relative to Msun for Mpart, default is 1e10 (i.e. 1e10*Msun)
}
  \item{Lunit}{
x, y, z distance unit scaling relative to parsecs, default is 1e3 (i.e. Kpc)
}
  \item{Vunit}{
vx, vy, vz velocity unit scaling relative to km/s, default is 1 (i.e. km/s)
}
  \item{IDoffset}{
The offset for the ID numbering- this is helpful when joining together multiple ICs
}
}

\details{
This function runs a Fortan routine that guarantees the gneerated halo is in thermal equilibrium.
}

\value{
  \item{part}{
A data.frame containing the main particle level information. Columns included are:
\tabular{ll}{
ID \tab particle ID\cr
x \tab x position in  units of Lunit (default Kpc)\cr
y \tab y position in  units of Lunit (default Kpc)\cr
z \tab z position in  units of Lunit (default Kpc)\cr
vx \tab x velocity in units of Vunit (default km/s)\cr
vy \tab y velocity in units of Vunit (default km/s)\cr
vz \tab z velocity in units of Vunit (default km/s)\cr
Mass \tab particle mass in units of Munit (default 1e10*Msun)\cr
}
}
  \item{params}{
A vector containing key set up information:
\tabular{ll}{
ID \tab particle ID\cr
Npart \tab Number of particles within Virial radius\cr
Mpart \tab Mass of each particle in units of Msun\cr
Mvir  \tab The mass of the halo within the virial radius in units of Msun\cr
Mtot  \tab The mass of all particles generated in units of Msun\cr
sigma \tab Velocity dispersion of particles (implied directly from Mvir) in units km/s\cr
conc  \tab Hernquist profile concentration\cr
iseed \tab Initial random seed\cr
}
}
}

\author{
Aaron Robotham, Chris Power
}

\seealso{
\code{\link{snapread}},\code{\link{snapwrite}},\code{\link{addhead}},\code{\link{genparam}},\code{\link{cosdist}},\code{\link{virialfuncs}}
}
\examples{

temp=genhalo()

str(temp)

plot(temp$part[,c('x','y')],pch='.',xlim=c(-100,100),ylim=c(-100,100))

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{gadget}
\keyword{halo}
