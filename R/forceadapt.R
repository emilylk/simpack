orbit=function(pos, vel, mass, timestep=1, Nstep=1, Munit = 1, Lunit = 1e3, Vunit=1, Tunit=1e6, soft=Lunit, adapt=100, minadsteps=10, maxadsteps=10) 
{
    
    if(!is.matrix(pos)){pos <- as.matrix(pos)}
    if(!is.matrix(vel)){vel <- as.matrix(vel)}
    if(ncol(pos)!=3){stop('pos must have 3 columns')}
    N = nrow(pos)
    
    if(length(mass) != 1 & length(mass) != N){
        stop("mass must be of length 1 or no. of rows in pos")
    }
    if(length(mass)==1){mass=rep(mass,N)}
    out <- .Fortran("orbitfor",
	poso = as.double(pos/(1e6/Lunit)),
	velo = as.double(vel/(1/Vunit)),
        accelo = as.double(rep(0,3*N)),
	masso = as.double(mass/(1e10/Munit)),
	No = as.integer(N),
	gpeo = as.double(rep(0,N)),
	keo = as.double(rep(0,N)),
        timestepo = as.double(timestep/(1e6/Tunit)),
        Nstep = as.integer(Nstep),
        soft = as.double(soft)/(1e6/Lunit),
        dolist = as.integer(rep(0,N)),
        adapt = as.double(adapt),
        maxadsteps = as.integer(minadsteps),
	maxadsteps = as.integer(maxadsteps),
	NAOK=TRUE,PACKAGE='simpack'
    )
#   accel in units (Vunit*km/s)/Myr by default
#   gpe in units (Munit*Msun)/(kms_to_ms*vunit)^2
    pos=matrix(out$pos*(1e6/Lunit), N,3)
    vel=matrix(out$vel*(1/Vunit), N, 3)
    accel=matrix(out$accel, N, 3)
    mass=out$mass*(1e10/Munit)


# find CoM of frame:

    CoM=colSums(pos*mass)/sum(mass)

# fins CoV of frame

    CoV=colSums(vel*mass)/sum(mass)

    gpe=-out$gpe*1e10/Munit
    ke=0.5*mass*((vel[,1]-CoV[1])^2+(vel[,2]-CoV[2])^2+(vel[,3]-CoV[3])^2)/(Vunit^2)
    gpetot=0.5*sum(gpe)
    ketot=sum(ke)

    return=list(pos=pos, vel=vel, accel=accel, mass=mass, CoM=CoM, CoV=CoV, gpe=gpe, ke=ke, energy=c(gpetot=gpetot, ketot=ketot, etot=gpetot+ketot, virialratio=abs((2*ketot)/gpetot)))
}

addenergy=function(snap, Munit = 1, Lunit = 1e3, Vunit=1){
mass=snap$part[,8]*(1/Munit)
vel=snap$part[,5:7]*(1/Vunit)
gpe=snap$extramat*mass*(1/Munit)/(1e3/Lunit)
CoV=colSums(vel*mass)/sum(mass)
ke=0.5*mass*((vel[,1]-CoV[1])^2+(vel[,2]-CoV[2])^2+(vel[,3]-CoV[3])^2)
snap$part=cbind(snap$part,gpe=gpe,ke=ke)
return=snap
}

accel=function(pos, mass, Munit = 1, Lunit = 1e3, soft=1) 
{
    
    if(!is.matrix(pos)){pos <- as.matrix(pos)}
    if(ncol(pos)!=3){stop('pos must have 3 columns')}
    N = nrow(pos)
    
    if(length(mass) != 1 & length(mass) != N){
        stop("mass must be of length 1 or no. of rows in pos")
    }
    if(length(mass)==1){mass=rep(mass,N)}
    out <- .Fortran("accelfor",
	posa = as.double(pos/(1e6/Lunit)),
	massa = as.double(mass/(1e10/Munit)),
	Na = as.integer(N),
	accela = as.double(rep(0,N*3)),
	gpe = -as.double(rep(0,N)),
        soft = as.double(soft)/(1e6/Lunit),
        dolist= as.integer(rep(0,N)),
	NAOK=TRUE,PACKAGE='simpack'
    )
#   accel in units (Vunit*km/s)/Myr by default
#   gpe in units (Munit*Msun)/(kms_to_ms*vunit)^2

    gpe=-out$gpe*1e10/Munit
    gpetot=0.5*sum(gpe) #0.5 because all potentials are measured twice

    return=list(accel = matrix(out$accel, N, 3), gpe=gpe, gpetot=gpetot)
}

potden=function(pos, mass, grid, bins, Munit = 1, Lunit = 1e3, soft=1) 
{
    
    if(!is.matrix(pos)){pos <- as.matrix(pos)}
    if(ncol(pos)!=3){stop('pos must have 3 columns')}
    N = nrow(pos)
    
    if(length(mass) != 1 & length(mass) != N){
        stop("mass must be of length 1 or no. of rows in pos")
    }
    if(length(mass)==1){mass=rep(mass,N)}
    
    if(is.vector(grid)){grid=expand.grid(grid,grid,grid)}
    if(length(bins)==1){bins=rep(bins,3)}
    if(length(bins)!=3){stop('Length of bins must be 1 or 3')}
    if(!is.matrix(grid)){grid <- as.matrix(grid)}
    if(ncol(grid)!=3){stop('grid must have 3 columns or be a single vector')}
    Ngrid=nrow(grid)

    out <- .Fortran("potdenfor",
	posa = as.double(pos/(1e6/Lunit)),
	massa = as.double(mass/(1e10/Munit)),
	Na = as.integer(N),
        soft = as.double(soft)/(1e6/Lunit),
        grida = as.double(grid)/(1e6/Lunit),
	potgrida = as.double(rep(0,Ngrid)),
	dengrida = as.double(rep(0,Ngrid)),
	bina = as.double(bins)/(1e6/Lunit),
	Ncella = Ngrid,
	NAOK=TRUE,PACKAGE='simpack'
    )
#   accel in units (Vunit*km/s)/Myr by default
#   gpe in units (Munit*Msun)/(kms_to_ms*vunit)^2

    colnames(grid)=c('x','y','z')
    mass=out$dengrida*(1e10/Munit)
    den=mass/(bins[1]*bins[2]*bins[3])
    pot=out$potgrida

    x=sort(unique(grid[,'x']))
    y=sort(unique(grid[,'y']))
    z=sort(unique(grid[,'z']))
    Nx=length(x)
    Ny=length(y)
    Nz=length(z)

    return=list(mat=cbind(grid,mass,den,pot),arrden=list(x=x,y=y,z=z,t=array(den,dim=c(Nx,Ny,Nz))),arrpot=list(x=x,y=y,z=z,t=array(pot,dim=c(Nx,Ny,Nz))),bins=bins)
}

