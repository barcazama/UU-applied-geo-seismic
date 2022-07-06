import numpy as np
from gpoly import gpoly
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from builtins import range

def ReadInpFile(filename,mode,saveMode,fitPro):

    # Required Input file "poly.inp" in the following format:
    #---------------------------------------------------------------------------------
    # title            <---- Title/Name of the model
    # xmin xmax delx   <---- start, end and interval of profile
    # npoly            <---- # of polygons
    # nc1 rho1         <---- # of vertices and density perturbation of first polygon
    # xc(1) zc(1)      <---- vertices ordered clockwise wrt downward pointing z-axis
    # xc(2) zc(2)
    # ...
    # xc(nc) zc(nc)
    # nc2 rho2         <---- # of vertices and density perturbation of second polygon
    # xc(1) zc(1)      <---- vertices ordered clockwise wrt downward pointing z-axis
    # xc(2) zc(2)
    # ...
    # xc(nc2) zc(nc2)
    # ....
    #---------------------------------------------------------------------------------
    #
    # Author: Andy McAliley
    # Date:   9/16/2017
    # Adapted from poly.m by Yaoguo Li
    # Written for the GPGN304 lab
    # modified by Leon Diekmann
    # 
    # mode: 0 to show everything, i.e. potential, anomaly, gradient and structures
    #       1 to show anomaly and structures
    #       2 to show gradient and structures
    # saveMode: 0 to save nothing
    #           1 to save anomaly data
    #           2 to save gradient data
    # fitPro: 0 no comparison with mystery data
    #         1 comparison with mystery data 

    # load data
    f = open(filename,'r')
    lines = f.read().splitlines()
    f.close()
    # parse header info
    title = lines[0]
    [xmin, xmax, xstep] = [float(i) for i in lines[1].split()]
    nobs = int((xmax-xmin)/xstep)+1
    xobs = np.linspace(xmin,xmax,nobs)
    obs = np.zeros((nobs,2))
    obs[:,0] = xobs
    npoly = int(lines[2])
    # load data for fitting
    if fitPro == 1:
        datAno = np.loadtxt('mysteryDataAnomaly.txt',dtype='float',delimiter=',')
        datGra = np.loadtxt('mysteryDataGradient.txt',dtype='float',delimiter=',')
    # prepare figure
    if mode == 0:
        plt.rcParams["figure.figsize"] = (15,10) 
        fig = plt.figure()
        axDataPot = fig.add_subplot(4,1,1)
        axDataZGrad = fig.add_subplot(4,1,2,sharex=axDataPot)
        axDataZZGrad = fig.add_subplot(4,1,3,sharex=axDataPot)
        axModel = fig.add_subplot(4,1,4,sharex=axDataPot)
        axModel.invert_yaxis()
        axDataPot.set_ylabel('potential [$m^2s^{-2}$]')
        axDataZGrad.set_ylabel('anomaly [m$s^{-2}$]')
        axDataZZGrad.set_ylabel('gradient [$s^{-2}$]')
        axModel.set_ylabel('z-axis [m]')
    elif mode == 1:
        plt.rcParams["figure.figsize"] = (15,5) 
        fig = plt.figure()
        axDataZGrad = fig.add_subplot(2,1,1)
        axModel = fig.add_subplot(2,1,2,sharex=axDataZGrad)
        axModel.invert_yaxis()
        axDataZGrad.set_ylabel('anomaly [m$s^{-2}$]')
        axModel.set_ylabel('z-axis [m]')   
    elif mode == 2:
        plt.rcParams["figure.figsize"] = (15,5) 
        fig = plt.figure()
        axDataZZGrad = fig.add_subplot(2,1,1)
        axModel = fig.add_subplot(2,1,2,sharex=axDataZZGrad)
        axModel.invert_yaxis()
        axDataZZGrad.set_ylabel('gradient [$s^{-2}$]')
        axModel.set_ylabel('z-axis [m]')          
    plt.xlabel('x-axis [m]')
    # compute potential    
    gravPot = computePot(nobs,npoly,lines,obs,0,0,axModel,0)
    if mode == 0:
        axDataPot.plot(xobs,gravPot,'g')
    # compute anomaly
    xzShift = 10**(-3)
    gravZA = computePot(nobs,npoly,lines,obs,0,xzShift,axModel,1)
    gravZGrad = -(gravPot-gravZA)/xzShift
    if mode == 0 or mode == 1: 
        axDataZGrad.plot(xobs,gravZGrad,'b')  
        if fitPro == 1:
            axDataZGrad.plot(datAno[:,0],datAno[:,1],'m--')  
    # compute zz gradient
    gravZB = computePot(nobs,npoly,lines,obs,0,-xzShift,axModel,1)
    gravZZGrad = (gravZB-2*gravPot+gravZA)/xzShift**2
    if mode == 0 or mode == 2:
        axDataZZGrad.plot(xobs,gravZZGrad,'r')
        if fitPro == 1:
            axDataZZGrad.plot(datGra[:,0],datGra[:,1],'m--')  
    if saveMode == 1:    
        np.savetxt('myAnomalyData.txt',gravZGrad,delimiter=',')
    elif saveMode == 2:
        np.savetxt('myGradientData.txt',gravZZGrad,delimiter=',')

def computePot(nobs,npoly,lines,obs,xShift,zShift,axModel,plotPoly):
    grav = np.zeros(nobs)
    nextLine = 3
    for ipoly in range(npoly):
        headerNums = lines[nextLine].split()
        nextLine = nextLine + 1
        nc = int(headerNums[0])
        density = float(headerNums[1])
        nodes = np.zeros((nc,2))
        for ic in range(nc):
            nodes[ic] = [float(i) for i in lines[nextLine].split()]
            nodes[ic,0] = nodes[ic,0]+xShift
            nodes[ic,1] = nodes[ic,1]+zShift
            nextLine = nextLine + 1
        if plotPoly == 1:
            axModel.plot(np.append(nodes[:,0],nodes[0,0]),np.append(nodes[:,1],nodes[0,1]),'k-')
            axModel.plot([obs[0],obs[-1]],[0,0],'c-')
            axModel.set_aspect('equal', 'datalim')
        # compute gravity anomaly for this polygon
        grav = grav + gpoly(obs,nodes,density)
    return grav
