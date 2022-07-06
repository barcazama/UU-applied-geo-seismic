# compute gravity response of a polygon
# Andy McAliley, 9/16/2017
import numpy as np
from builtins import range

def gpoly(obs,nodes,density):
    #Blakely, 1996
    gamma = 6.672E-03;
    numobs = len(obs)
    numnodes = len(nodes)
    grav = np.zeros(numobs)
    for iobs in range(numobs):
        shiftNodes = nodes - obs[iobs]
        sum = 0
        for i1 in range(numnodes):
            i2 = i1+1
            # last node must wrap around to first node
            i2 = np.mod(i2,numnodes)
            x1 = shiftNodes[i1,0]
            x2 = shiftNodes[i2,0]
            z1 = shiftNodes[i1,1]
            z2 = shiftNodes[i2,1]
            dx = x2 - x1
            dz = z2 - z1
            # avoid zero division
            if abs(dz) < 1E-8:
                # move on if points are identical
                if abs(dx) < 1E-8:
                    continue
                dz = dz - dx*(1E-7)
            alpha = dx/dz
            beta = x1-alpha*z1
            r1 = np.sqrt(x1**2+z1**2)
            r2 = np.sqrt(x2**2+z2**2)
            theta1 = np.arctan2(z1,x1)
            theta2 = np.arctan2(z2,x2)

            term1 = np.log(r2/r1)
            term2 = alpha*(theta2-theta1)
            factor = beta/(1+alpha**2)
            sum = sum + factor*(term1-term2)
        grav[iobs] = 2*gamma*density*sum
    return grav
