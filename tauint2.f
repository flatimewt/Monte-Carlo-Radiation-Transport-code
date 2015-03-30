      subroutine tauint2(xp,yp,zp,nxp,nyp,nzp,xmax,ymax,zmax,Rr,Tr,cnt
     +              ,kappa,xface,yface,zface,rhokap,zpos,phi,dectang,pi,
     +               twopi,xcell,ycell,zcell,tflag,iseed,delta,th,rbins,
     +                jmean,ph1,ph2,ph3,ydect,xdect,rdect,ddr,numberrun,
     +            weight,sint,n2,n1,cost,sflag,xcur,ycur,zcur,cosp,sinp)

      implicit none

      include 'grid.txt'

      integer tflag,iseed,xcell,ycell,zcell,ph1,ph2,ph3,sflag,numberrun
      real xp,yp,zp,nxp,nyp,nzp,xmax,ymax,zmax,phi,ddr,Rr(0:rbins-1)
      real xpos,ypos,zpos,tpos,n1,n2,sint,cost,weight,noise(1:cnt,1:cnt)
      real ran2,pi,twopi,kappa,taue

      integer celli,cellj,cellk,rbins,rflag,pflag,cnt
      real tau,taurun,taucell,d,d1,dcell,xcur,ycur,zcur,dsx,dsy,dsz
      real dx,dy,dz,smax,delta,ydect,xdect,rdect,dectang,th,cosp,sinp
      real Tr(0:rbins-1)
c      real jmean(nxg,nyg,nzg)

c***** tflag=0 means photon is in envelope
      tflag=0
      
      if(pflag.eq.1) then
      taue=kappa*2.*zmax
      tau=-log(1-ran2(iseed)*(1-exp(-taue)))
      pflag=0
      else
      

c**** generate random optical depth tau
      tau=-alog(ran2(iseed))
      end if
      
c***** set the cumulative distance and optical depth (d and taurun) 
c***** along the photon path to zero.  set the current photon coordinates.
c***** note that the origin of the (xcur,ycur,zcur) system is at the 
c***** bottom corner of the grid.
      taurun=0.    
      xcur=xp+xmax
      ycur=yp+ymax
      zcur=zp+zmax
      
      celli=xcell
      cellj=ycell
      cellk=zcell 
        
345   continue
      if (cellk.lt.1 )cellk=1 
      d=0.

c***** calculate smax -- maximum distance photon can travel
      if(nxp.gt.0.) then
         dsx=(2.*xmax-xcur)/nxp
      elseif(nxp.lt.0.) then
         dsx=-xcur/nxp
      elseif(nxp.eq.0.) then
         dsx=1.e2*xmax
      endif

      if(nyp.gt.0.) then
         dsy=(2.*ymax-ycur)/nyp
      elseif(nyp.lt.0.) then
         dsy=-ycur/nyp
      elseif(nyp.eq.0.) then
         dsy=1.e2*ymax
      endif

      if(nzp.gt.0.) then
         dsz=(2.*zmax-zcur)/nzp
      elseif(nzp.lt.0.) then
         dsz=-zcur/nzp
      elseif(nzp.eq.0.) then
         dsz=1.e2*zmax
      endif

      smax=amin1(dsx,dsy,dsz)
      if(smax.lt.delta) then
         tflag=1
         return
      endif
       
c***** integrate through grid
      do while((taurun.lt.tau).and.(d.lt.(.999*smax)))

c***** find distance to next x, y, and z cell walls.  
c***** note that dx is not the x-distance, but the actual distance along 
c*****the direction of travel to the next x-face, and likewise for dy and dz.
         if(nxp.gt.0.) then
            dx=(xface(celli+1)-xcur)/nxp
            if(dx.lt.delta) then
               xcur=xface(celli+1)
               celli=celli+1
               dx=(xface(celli+1)-xcur)/nxp
            endif
         elseif(nxp.lt.0.) then
            dx=(xface(celli)-xcur)/nxp
            if(dx.lt.delta) then
                  if(celli.lt.2)celli=2
               xcur=xface(celli)
               dx=(xface(celli-1)-xcur)/nxp
               celli=celli-1
            endif
         elseif(nxp.eq.0.) then
            dx=1.e2*xmax
         endif

         if(nyp.gt.0.) then
            dy=(yface(cellj+1)-ycur)/nyp
            if(dy.lt.delta) then
               ycur=yface(cellj+1)
               cellj=cellj+1
               dy=(yface(cellj+1)-ycur)/nyp
            endif
         elseif(nyp.lt.0.) then
            dy=(yface(cellj)-ycur)/nyp
            if(dy.lt.delta) then
               ycur=yface(cellj)
               if(cellj-1.eq.0) cellj=2
               dy=(yface(cellj-1)-ycur)/nyp
               cellj=cellj-1
            endif
         elseif(nyp.eq.0.) then
            dy=1.e2*ymax
         endif

         if(nzp.gt.0.) then
            dz=(zface(cellk+1)-zcur)/nzp
            if(dz.lt.delta) then
               zcur=zface(cellk+1)
               cellk=cellk+1
               dz=(zface(cellk+1)-zcur)/nzp
            endif
         elseif(nzp.lt.0.) then
            if (cellk.gt.nzg+3) then
            cellk=nzg+3
            print *, 'cellk > 204',zcur
            end if
            dz=(zface(cellk)-zcur)/nzp
            if(dz.lt.delta) then
               zcur=zface(cellk)
               if(cellk.lt.2) then
               cellk=2
               print *, 'cellk < 2'
               end if
               dz=(zface(cellk-1)-zcur)/nzp
               cellk=cellk-1
               if(cellk.lt.1.) then
                  print *, 'cellk<1'
                  cellk=1
               end if
            endif
         elseif(nzp.eq.0.) then
            dz=1.e2*zmax
         endif

c***** distances are only zero if photon is on cell wall.  if it is 
c***** on cell wall then set to arbitrary large distance, since we will
c***** in fact hit another wall
         if( (dx.eq.0.) .or. ((abs(dx)).lt.(delta)) ) dx=1.e2*xmax
         if( (dy.eq.0.) .or. ((abs(dy)).lt.(delta)) ) dy=1.e2*ymax
         if( (dz.eq.0.) .or. ((abs(dz)).lt.(delta)) ) dz=1.e2*zmax
            
c***** find distance to next cell wall -- minimum of dx, dy, and dz
         dcell=amin1(dx,dy,dz)
         if(dcell.le.0.) then
            print *,'tauint2: dcell < 0'
         endif
         if(dx.lt.0.) dcell=amin1(dy,dz)
         if(dy.lt.0.) dcell=amin1(dx,dz)
         if(dz.lt.0.) dcell=amin1(dx,dy)

c***** optical depth to next cell wall is 
c***** taucell= (distance to cell)*(opacity of current cell)
            if(cellk.gt.204)then
            print *,'cellk=204'
            cellk=204
            end if
         taucell=dcell*rhokap(celli,cellj,cellk)

c***** if taurun+taucell>tau then scatter at distance d+d1.  
c***** update photon position and cell.  
c***** if taurun+taucell<tau then photon moves distance dcell 
c***** (i.e. ends up on next cell wall) and update photon position
c***** and cell.
         if((taurun+taucell).ge.tau) then
            d1=(tau-taurun)/rhokap(celli,cellj,cellk)
            d=d+d1
            taurun=taurun+taucell
            xcur=xcur+d1*nxp
            ycur=ycur+d1*nyp
            zcur=zcur+d1*nzp
            jmean(celli,cellj,cellk) = jmean(celli,cellj,cellk) + d1

c*************** Linear Grid ************************
            celli=int(nxg*xcur/(2.*xmax))+1
            cellj=int(nyg*ycur/(2.*ymax))+1
            cellk=int(nzg*zcur/(2.*zmax))+1
c****************************************************

         else

            d=d+dcell
            taurun=taurun+taucell
            xcur=xcur+dcell*nxp
            ycur=ycur+dcell*nyp
            zcur=zcur+dcell*nzp
            jmean(celli,cellj,cellk) = jmean(celli,cellj,cellk) + dcell
c*************** Linear Grid ************************
            celli=int(nxg*xcur/(2.*xmax))+1
            cellj=int(nyg*ycur/(2.*ymax))+1
            cellk=int(nzg*zcur/(2.*zmax))+1
c****************************************************

          endif
      end do
      
c***** calculate photon final position.  if it escapes envelope then
c***** set tflag=1.  if photon doesn't escape leave tflag=0 and update 
c***** photon position.
!      if(numberrun.ge.955000) print *, numberrun,xcur,ycur,zcur
      if((d.ge.(.9999999*smax))) then
          if((xcur.ge..9999999**2.*xmax).or.(xcur.le.1.0E-7)) tflag=1
          if((ycur.ge..9999999*2.*ymax).or.(ycur.le.1.0E-7)) tflag=1
!          if(zcur.le.1.0E-7) tflag=1
          if((zcur.ge..9999999*2.*zmax).or.zcur.le.1.0E-7) then
         call fresnel(sint,cost,sinp,cosp,nxp,nyp,nzp,tflag
     +            ,iseed,n1,n2,xp,yp,zp,xcur,ycur,Rr,ddr,weight
     +       ,xmax,ymax,zmax,zcur,rbins,Tr,sflag,rflag,noise,cnt)



!            if(rflag.eq.1) then
!              xp=xcur-xmax
!              yp=ycur-ymax
!              zp=zcur-zmax

!              cost=cos(pi-asin(sint)) ! reflect photon
!              sint=(1.-cost*cost)
!              if(sint.le.0.)then
!                sint=0.
!              else
!                sint=sqrt(sint)
!              endif
!              nxp=sint*cosp  
!              nyp=sint*sinp
!              nzp=cost

              goto 345
!            endif
            
          else
                  tflag=1
          end if        
      else
         xp=xp+d*nxp
         yp=yp+d*nyp
         zp=zp+d*nzp
         xcell=int(nxg*(xp+xmax)/(2.*xmax))+1
         ycell=int(nyg*(yp+ymax)/(2.*ymax))+1
         zcell=int(nzg*(zp+zmax)/(2.*zmax))+1
         
         
      endif

      return
      end
